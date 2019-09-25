# HyperTester Compiler Wiki

This doc is about the specification of `HyperTester` primitives and its compiler implementation.

### OverView

The HyperTester Compiler takes in the trigger and query primitives specified by users, and spits out three kind of outputs:

* **Template Packet Config**: used by switch CPU program to generate template packets, template packet configuration includes `tmpl_id`, initial value of header fields, format of payload and so on.
* **P4 Code Config**: HyperTester use `jinja2` template engine to produce the final p4 codes. The jinja2 takes in a series of p4 code templates we have made up in advance and the p4 code configuration file output by the `HyperTester` compiler. The p4 code templates are under `compiler` directory.
* **Control Commands**: used by control plane to install table entries on dataplane.

---

### Primitive Grammar

#### 1. Trigger

```
trigger( [qid, delay_install] )
	[ .set(field_list, value_list) ]+
	[ .set(field, value) ]+
```

`field` includes header fields, payload, and control fields like `loop`, `length`, `port`, `interval`.

the type of value supported differs from the kind of field:

* header fields support `CONSTANT_VALUE`, `ARRAY_VALUE`, `RANGE_VALUE`, and `RANDOM_VALUE`.

* `interval` supports `CONSTANT_VALUE` and `RANDOM_VALUE`.

* Other fields including `loop`, `payload`, `length`, and `port` only support `CONSTANT_VALUE`.

#### 2. Query

```
query(trigger=None, aggregate_time=None)
	.filter(...)
	.map(...)
	.distinct(...)
	.reduce(...)
```

similiar to Sonata’s.

#### 3. Basic Data Structure

###### HTValue

```
HTValue('CONSTANT', 100) 
HTValue('ARRAY', [ 1, 2, 3, 4]) 
HTValue('RANGE_ARRAY', (0, 100, 1)) 
HTValue('RANDOM_ARRAY', ('Uniform', [1, 100], 2000)) 
HTValue('RANDOM_ARRAY', ('Gaussian', [0, 1], 1000)) 
```

HTValue can be constructed in the form of ` HTValue(TYPE, VALUE)`.

There are 4 kind of HTValues: {“CONSTANT”, “ARRAY”, “RANGE_ARRAY”, “RANDOM_ARRAY”}

* For `CONSTANT_VALUE` or `ARRAY_VALUE` type, the VALUE parameter is the constant value or list value itself.

* For `RANGE_VALUE`, the VALUE is a tuple of `(start, stop, step)`.

* For `RANDOM_VALUE`, the VALUE is also a tuple, and the first argument is the name of the distribution, e.g. Uniform, Gaussian, Exponential and so on. while the second argument differs from different distribution, it’s another tuple composed of a set of arguments representing the characteristic of the distribution. For example, ‘Uniform’ distribution can be fully decided by fixing`(lowerbound, upperbound)`, and ‘Gaussian’ distribution can be determined by `(mu, sigma)`. The final parameter of random value tuple is the number of samples.

---

### Compiler Implementation

#### Trigger Part

1. replicator

   * **input**: `set(“interval”, TIME_VALUE)` in trigger primitives

   * **output**:

     * **Tmpl_pkt_conf:** `(ht.pkt_interval, TIME_VALUE)`, this value can be zero when in FULL_SPEED and RANDOM_RATE replicator condition.

     * **P4_code_conf:**

       will output a list `replicators`, whose elements are replicator instances.

       replicator has 3 kind of types: {“FULL_SPEED”，“CONSTANT_RATE”，"RANDOM_RATE” }. The type of replicator will be decided by the value of interval parameter. The value type of interval can be `CONSTANT_VALUE` or `RANDOM_VALUE`.

       * For `FULL_SPEED`: replicator instance must contain member variables {“.type”, “.size”}, where `type=“FULL_SPEED”`, and the value of `size` is the number of template packets using “FULL_SPEED” replicator.
       * For `CONSTANT_RATE`:  replicator instance must contain member variables {“.type”, “.size”}, where `type=“CONSTANT_RATE”`, and the value of `size` is the number of template packets using “CONSTANT_RATE” replicator.

       * For RANDOM_RATE`:  replicator instance must contain member variables {“.type”, “.size”}, where `type=“RANDOM_RATE”`, and the value of `size` is the number of template packets using “RANDOM_RATE” replicator.

     * **Ctrl_cmds:** 

       To support multiple kind of replicators simultaneously, we have a table `select_replicator`, which choose replicator for different template packet. The table entry maps `ht.template_id -> {goto_fs_replicator, goto_cr_replicator, goto_rr_replicator}`.

       Besides,

       * For `FULL_SPEED`:
         1. table `fs_replicate` needs table entries to map `ht.template_id -> do_multicast`, and the action has a parameter of `mcast_group`.
       * For `CONSTANT_RATE`:
         1. table `load_rc_timestamp` needs `ht.template_id -> do_load_rc_timestamp`, where action parameter is `reg_id`, which is a separate index for template packets using CONSTANT_RATE replicator.
         2. table `rc_replicate` needs `ht.template_id -> do_rc_multicast`, where action parameters are `reg_id` and `cast_group`.
       * For `RANDOM_RATE`:
         1. table `get_rr_possibilty` needs the default action `do_get_rr_possibilty`, which will generate a random number and assign it to `rr_md.possibility`.
         2. table `get_rr_interval` needs to map`(ht.template_id, rr_md.possibility[range]）-> do_get_rr_interval`. Here we use the ability of range match to produce traffic approximating arbitary distribution. The parameters of `do_get_rr_interval` are `lower_bound, upper_bound`.
         3. table `load_rr_timestamp` is similar to `CONSTANT_RATE`’s . Mapping`ht.template_id -> do_load_rr_timestamp`, parameter is `reg_id`.
         4. table `rr_replicate` is similar to `CONSTANT_RATE`’s. needs `ht.template_id ->  do_rr_multicast`, parameters for action are `reg_id, mcast_grp`.

2. editor

   * **input**: `set(HEADER_FIELD, HT_VALUE)` in trigger primitives

   * **output**: 

     each header field specified in primitives will has a corrensponding editor. There are 4 editor types: {“CONSTANT”, “ARRAY”, “RANGE_ARRAY”, “RANDOM_ARRAY”}, and the type of editor will be decided by the type of HTVALUE.

     * **Tmpl_pkt_conf:** 

       set the initial value for header field according to the type of editor,`[(header, init_val)+]`:

       * `CONSTANT`：the constant value；
       * `ARRAY`: the first value in array list；
       * `RANGE_ARRAY`: the start value of range expression；
       * `RANDOM_ARRAY`: 0;

     * **P4_code_conf:**

       will output a list `editors`, which consists of editor instances. Each header field accompanied with the editor type will has a corrensponding editor existed.

       Each editor must have {“.name”, “.type”} as its member variables, and the `editor.name` must be unique, so we take the naming convention as `field+editor.type`.

       Besides, some additional member variables are neened by different editors.

       * `CONSTANT`：no extra member variables needsed;
       * `ARRAY`: a list member variable `.fields`, whose elements are `field`. `field.p4` is the field identifier string in p4 codes, and `field.id` is the field name represented and used by compiler. “ARRAY” editor is able to set multiple fields simultaneously, that’s why we use `fields` here.
       * `RANGE_ARRAY`:  `.fields[0].size`, specifying the first field’s bit width. `fields[0].p4` the field identifier string in p4 codes. Up to now, our compiler only support at most **one** field in “RANGE” editor, and compiler will check if `len(fields)>1`, which will raise an error. The support for multi-fields is our future work.
       * `RANDOM_ARRAY`:no extra member variables needsed;

     * **Ctrl_cmds:** 

       * `CONSTANT`：nothing;
       * `ARRAY`: 
         1. table `get_{{ editor.name }}_pkt_id`, needs to map `tmpl_id -> reg_id`, where `reg_id` is a separate index for template packet using ARRAY editor. The index will be used to access the register array, which store the current interation position `pkt_id` of the array list.
         2. table `set_{{ editor.name }}`  ,  maps `(tmpl_id, pkt_id) -> {"do_set_{{ editor.name }}","do_set_{{ editor.name }}_with_wrap”}`. The first action set the correct array list value to corresponding field, while the last action reset the `pkt_id`. The logic of array list is realized by an array list of table entries, indexed by `pkt_id`. 
       * `RANGE_ARRAY`: 
         1. table `set_{{ editor.name }}`, similar as “ARRAY” editor’s, but match the `tmpl_id`, get the `reg_id`, but register pointed by `reg_id` stores the current range iteration value instead of `pkt_id`.
         2. table `wrap_{{ editor.name }}` is to reset the counting register to its initial value. 
       * `RANDOM_ARRAY`:
         1. table `get_{{ editor.name }}_possibilty`, the default action is `do_get_{{ editor.name }}_possibilty`;
         2. table `set_{{ editor.name }}`,  mapping `(tmpl_id, possibility[range])`to the random value. We leverage the flexiable range match to approximate distributions.

3. accelerator

   * **input**: `set(“loop”, CONSTANT)` in trigger primitives

   * **output**: 

     * **Tmpl_pkt_conf:** Nothing.

     * **P4_code_conf:**

       accelerator will stop to recirculate when `loop_cnt` reach the `loop` setted in trigger primitive.

     * **Ctrl_cmds:** 

       1. table `acc_recirculation` has a default action `do_recirc_acc`.

4. misc

   * **input**: `set(“length”, CONSTANT) / set(“port”, CONSTANT)` in trigger primitives

   * **output**: 

     * **Tmpl_pkt_conf:** 

       `length` control the packet length of template packet;

        `port` is used to control the multicast group.

     * **P4_code_conf:** Nothing;

     * **Ctrl_cmds:** Nothing.

#### Query Part

1. filter

   * **input**: `filter(LEFT, OP, RIGHT)` in query primitives

     ```
     example:
     .filter('ipv4.protocol','eq', 6)
     .filter('tcp.flags','eq', 2)
     ```

   * **output**: 

     * **Tmpl_pkt_conf:** Nothing;

     * **P4_code_conf:**

       will output a list `filters`, which contains `fl`s. For each `fl`:

       * `fl.name` is the unique identifier for every filter `fl`;
       * jinja2 will change the control logic in template p4 codes by substituting ` if ( {{ fl.predicate.left }} {{ fl.predicate.op }} {{ fl.predicate.right }} ) `.

     * **Ctrl_cmds:** 

       1. table `pass_{{ fl.name }}` ’s default action `do_pass_{{ fl.name }}`.

2. map

3. distinct

   * **input**:  `distinct(KEYS)` in query primitives

     ```
     example:
     .distinct(keys=('ipv4.dstIP', 'ipv4.srcIP', 'ipv4.totalLen'))
     .distinct(keys=('ipv4.srcIP', 'tcp.dport'))
     ```

   * **output**: 

     * **Tmpl_pkt_conf:** Nothing; In standard p4 specification, we can access register anywhere.

     * **P4_code_conf:**

       will output a list `distinct_queries`, which contains every distinct primitive as a `distinct` instance. We will explain the member variables of `distinct` here:

       * `distinct.name`：unique identifier；
       * `distinct.key_fields`: the field list for matching, where `distinct.key_fields[i].p4` is the  identifier string of the match field in p4 codes.
       * `distinct.conflict_num`: a number calculated by compiler, which is the number of possible  hash collision in header space specified by the field list.

     * **Ctrl_cmds:** 

       1. `check_{{ distinct.name }}` is to filter out the packet may have collisions. Compiler needs to take the whole header space into account to get table entries. The header space is constrained by specified field list.

       2. `hash_{{ distinct.name }}`, the default action is `do_hash\_{{ distinct.name }}`. To calculate the hash value.

       3. `query_{{ distinct.name }}`, the default action is `do_query\_{{ distinct.name }}`. To access the register array using the hash value we got.

       4. `update_{{ distinct.name }}` is used to update the cuckoo hash data structure we designed to accommodate the distinct results. We leverage the capacity of tenary match to check  `query_res{1,2}，dgst{1,2}`.

          * if one of`query_res{1,2}` is 0, the action will be `do_not_update_{{ distinct.name }}`, and the result for query is DUPICATE;
          * if one of`dgst{1,2}` is 0, the space in register{1,2} is still unused. We put `dgst` into this empty place, and set the result metadata as DISTINCT;
          * otherwise, we will do `do_update_{{ distinct.name }}`, which put `dgst` to register array 1, and put `dgst1` stored in register array 1 to register array 2, and send `dgst2` to CPU.

          the table entries for distinct can be summarized below:

          | res1 | res2 | dgst1 | dgst2 |                 action                 | Priority |
          | :--: | :--: | :---: | :---: | :------------------------------------: | :------: |
          |  0   |  *   |   *   |   *   |   do_not_update_{{ distinct.name }}    |    0     |
          |  *   |  0   |   *   |   *   |   do_not_update_{{ distinct.name }}    |    1     |
          |  *   |  *   |   0   |   *   | do_update\_{{ distinct.name }}\_array1 |    2     |
          |  *   |  *   |   *   |   0   | do_update\_{{ distinct.name }}\_array2 |    3     |
          |  *   |  *   |   *   |   *   |     do_update_{{ distinct.name }}      |    4     |

4. reduce

   * **input**:  `reduce(KEYS)` in query primitives

     ```
     example:
     .reduce(keys=('ipv4.dstIP',), func=('sum',))
     ## Up to now, our compiler only support `sum` function.
     ```

   * **output**: 

     - **Tmpl_pkt_conf:** Nothing; In standard p4 specification, we can access register anywhere.

     - **P4_code_conf:**

       will output `reduce_queries`, whose elements are `reduce` instance. The `reduce` instance has member variables as:

       * `reduce.name`: unique identifier；
       * `reduce.key_fields`: a list of keys, where `key.p4` is the identifier string of field in p4 tempate codes.
       * `reduce.conflict_num`: number of collisions.

     - **Ctrl_cmds:** 

       1. table `check_{{ reduce.name }}`, similar to DISTINCT’s, which will filter out collisions.

       2. table `hash\_{{ reduce.name }}`, whose default action is `do\_hash\_{{ reduce.name }}`.

       3. table `query\_{{ reduce.name }}`, the default action is `do\_query\_{{ reduce.name }}`.

       4. table `update_{{ reduce.name }}`, similar to DISTINCT’s.

          | res1 | res2 | dgst1 | dgst2 |                action                 | Priority |
          | :--: | :--: | :---: | :---: | :-----------------------------------: | :------: |
          |  0   |  *   |   *   |   *   | do_not_update_{{ reduce.name }}\_cnt1 |    0     |
          |  *   |  0   |   *   |   *   | do_not_update_{{ reduce.name }}\_cnt2 |    1     |
          |  *   |  *   |   0   |   *   | do_update\_{{ reduce.name }}\_array1  |    2     |
          |  *   |  *   |   *   |   0   | do_update\_{{ reduce.name }}\_array2  |    3     |
          |  *   |  *   |   *   |   *   |      do_update_{{ reduce.name }}      |    4     |

#### Control Flow

Control flow is used by compiler to glue the parts mentioned above.

1. Trigger

   the control flow logic of trigger is fixed. 

   * Trigger Ingress

   * Trigger Egress

2. Query

   the query primitives are connected like a link table.

   * Query Ingress

     The part of query logic resides in ingress pipeline only process and analysis the traffic that HyperTester **received**.

     * **input**: the whole query statement and the compiler outputs of every query primitive.

     * **output**: 

       * **P4_code_conf:**

         will output a list `ingress_queries`, whose element `query` is corresponding to each query. `query` ’s member variables are:

         * `query.name`: unique identifier for each query;
         * `query.primitives`: a list, whose member `primitive` is composed of primitive{.name, .type, .prev}. `primitive.prev` will return the last `primitive` instance.

   * Query Egress

     The part of query logic resides in ingress pipeline only process and analysis the traffic that HyperTester **sent out**.

     The input and output for egress is quite similar to ingress’s, except the data structure name is `egress_queries` rather than `ingress_queries`.

#### Utilities Functions

1. unique name generator

   ```python
   def generate_uid(...)
   ```

   To generate unique identifiers for all kinds of modules.

2. inverse transformer

   ```python
   def inverse_transform(...)
   ```

   To perform something like `inverse transform sampling`, and will output the table entires related to random distributions. 

   The output range of cumulative distribution function is [0,1]. We can evenly seperate the interval of [0,1] into 65536 equal-length segments. Each segment will has a corresponding interval in the input space of the cumulative distribution function. Obviously, intervals in input space are of different lengths, but they all have the same amount of possibility mass casue they are of a equal length in the output probability space.  Then we do an approximation on these input space intervals, we simply think that every input space interval satisfies uniform distribution, which takes up the possibility mass like before. Cause every interval has the same amount of possibility mass, we further divide each interval into 1024 equal parts, and use the minimal value of each part to represent the whole, which is something just like Analog-to-Digital discretization.  

   However, this kind of method will generate too many table entries. We can also control the intervals in input space with same ‘length', which will lead to different length in output space. The p4 language supports range match which is naturally suitable to realize this new method. We leverage the range match to segment a uniform distribution on [0,65535], thus each segment corresponds to a table entry who need to specify a parameter of `(lowerbound, upperbound)`. Cause each segment will have a equal length in input space, and we had carefully controlled this length. We can get the final random value by adding a 0~1023 random number to a `offset` value specified to each segment.

3. hash collision calculator

   ```python
   def calc_hash_collision(...)
   ```

   To calculate collisions given key list.

