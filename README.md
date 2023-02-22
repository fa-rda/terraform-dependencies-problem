## Problem with dependencies

The service can have multiple backends:

```
* Service
\
 + Backend(a)
 |
 + Backend(b)
 |
 + Backend(c)
```

Backends are described in `root.main.locals.backends`, alongside with the service module.
The service module uses `aws_s3_object` as a resource allowing in-place updating, in opposite to the `local_file`.

The initialization ordering looks OK:

```
module.t4["a"].time_sleep.backend: Creating...
module.t4["b"].time_sleep.backend: Creating...
module.t4["c"].time_sleep.backend: Creating...
module.t4["b"].time_sleep.backend: Still creating... [10s elapsed]
module.t4["c"].time_sleep.backend: Still creating... [10s elapsed]
module.t4["a"].time_sleep.backend: Still creating... [10s elapsed]
module.t4["a"].time_sleep.backend: Creation complete after 12s
module.t4["b"].time_sleep.backend: Creation complete after 14s
module.t4["c"].time_sleep.backend: Creation complete after 16s
module.service.aws_s3_object.services: Creating...
module.service.aws_s3_object.services: Creation complete after 2s [id=services.txt]

Apply complete! Resources: 4 added, 0 changed, 0 destroyed.
```

After successful initialization, we tried to remove the backend 'c', and expected the following order of operations:

```
module.service.aws_s3_object.services: Modifying...
module.service.aws_s3_object.services: Modifications complete after 2s [id=services.txt]
module.t4["c"].time_sleep.backend: Destroying...
module.t4["c"].time_sleep.backend: Still destroying...
module.t4["c"].time_sleep.backend: Destruction complete after 16s

Apply complete! Resources: 0 added, 1 changed, 1 destroyed.
```

But in practice terraform uses the following order of operations:

```
module.t4["c"].time_sleep.backend: Destroying...
module.t4["c"].time_sleep.backend: Still destroying...
module.t4["c"].time_sleep.backend: Destruction complete after 16s
module.service.aws_s3_object.services: Modifying... [id=services.txt]
module.service.aws_s3_object.services: Modifications complete after 1s [id=services.txt]

Apply complete! Resources: 0 added, 1 changed, 1 destroyed.
```

The main problem here is that the modification of the service was done only after the backend was removed.
The service can't use the removed backend, so the operation will be declined by the cloud service.
