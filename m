From: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Subject: [PATCH] c/r: export key symbols to enable c/r from kernel modules
Date: Mon, 15 Mar 2010 00:58:34 -0400
Message-ID: <1268629114-6793-1-git-send-email-orenl@cs.columbia.edu>
References: <20100315032347.GA4707@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20100315032347.GA4707-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Serge Hallyn <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

This will be important for modules that implement checkpoint-restart
logic, e.g. network devices.

(This intentionally does not fix the exports missing from netdev - I
expect that to be part a seperate cleanup patchset)

Signed-off-by: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
---
 checkpoint/checkpoint.c |    4 ++++
 checkpoint/objhash.c    |    8 ++++++++
 checkpoint/restart.c    |    8 ++++++++
 checkpoint/sys.c        |    6 ++++++
 4 files changed, 26 insertions(+), 0 deletions(-)

diff --git a/checkpoint/checkpoint.c b/checkpoint/checkpoint.c
index 466f594..4359106 100644
--- a/checkpoint/checkpoint.c
+++ b/checkpoint/checkpoint.c
@@ -41,6 +41,7 @@ int ckpt_write_obj(struct ckpt_ctx *ctx, struct ckpt_hdr *h)
 	_ckpt_debug(CKPT_DRW, "type %d len %d\n", h->type, h->len);
 	return ckpt_kwrite(ctx, h, h->len);
 }
+EXPORT_SYMBOL(ckpt_write_obj);
 
 /**
  * ckpt_write_obj_type - write an object (from a pointer)
@@ -73,6 +74,7 @@ int ckpt_write_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
 	_ckpt_hdr_put(ctx, h, sizeof(*h));
 	return ret;
 }
+EXPORT_SYMBOL(ckpt_write_obj_type);
 
 /**
  * ckpt_write_buffer - write an object of type buffer
@@ -84,6 +86,7 @@ int ckpt_write_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
 {
 	return ckpt_write_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
 }
+EXPORT_SYMBOL(ckpt_write_buffer);
 
 /**
  * ckpt_write_string - write an object of type string
@@ -95,6 +98,7 @@ int ckpt_write_string(struct ckpt_ctx *ctx, char *str, int len)
 {
 	return ckpt_write_obj_type(ctx, str, len, CKPT_HDR_STRING);
 }
+EXPORT_SYMBOL(ckpt_write_string);
 
 /***********************************************************************
  * Checkpoint
diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 8ca2664..e487ffc 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -813,6 +813,7 @@ int ckpt_obj_lookup(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 		ckpt_debug("%s objref %d\n", obj->ops->obj_name, obj->objref);
 	return obj ? obj->objref : 0;
 }
+EXPORT_SYMBOL(ckpt_obj_lookup);
 
 static inline int obj_reverse_leak(struct ckpt_ctx *ctx, struct ckpt_obj *obj)
 {
@@ -856,6 +857,7 @@ int ckpt_obj_lookup_add(struct ckpt_ctx *ctx, void *ptr,
 	obj->flags |= CKPT_OBJ_VISITED;
 	return obj->objref;
 }
+EXPORT_SYMBOL(ckpt_obj_lookup_add);
 
 /**
  * ckpt_obj_reserve - reserve an objref
@@ -869,6 +871,7 @@ int ckpt_obj_reserve(struct ckpt_ctx *ctx)
 {
 	return obj_alloc_objref(ctx);
 }
+EXPORT_SYMBOL(ckpt_obj_reserve);
 
 /**
  * checkpoint_obj - if not already in hash, add object and checkpoint
@@ -919,6 +922,7 @@ int checkpoint_obj(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	obj->flags |= CKPT_OBJ_VISITED;
 	return (ret < 0 ? ret : obj->objref);
 }
+EXPORT_SYMBOL(checkpoint_obj);
 
 /**
  * ckpt_obj_visit - mark object as visited
@@ -951,6 +955,7 @@ int ckpt_obj_visit(struct ckpt_ctx *ctx, void *ptr, enum obj_type type)
 	}
 	return 0;
 }
+EXPORT_SYMBOL(ckpt_obj_visit);
 
 /* increment the 'users' count of an object */
 static void ckpt_obj_users_inc(struct ckpt_ctx *ctx, void *ptr, int increment)
@@ -1152,6 +1157,7 @@ int ckpt_obj_insert(struct ckpt_ctx *ctx, void *ptr,
 	ckpt_debug("%s objref %d\n", obj->ops->obj_name, objref);
 	return obj->objref;
 }
+EXPORT_SYMBOL(ckpt_obj_insert);
 
 /**
  * ckpt_obj_try_fetch - fetch an object by its identifier
@@ -1176,6 +1182,7 @@ void *ckpt_obj_try_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 		return obj->ptr;
 	return ERR_PTR(-ENOMSG);
 }
+EXPORT_SYMBOL(ckpt_obj_try_fetch);
 
 void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 {
@@ -1186,6 +1193,7 @@ void *ckpt_obj_fetch(struct ckpt_ctx *ctx, int objref, enum obj_type type)
 			 objref, type);
 	return ret;
 }
+EXPORT_SYMBOL(ckpt_obj_fetch);
 
 /*
  * checkpoint a security context string.  This is done by
diff --git a/checkpoint/restart.c b/checkpoint/restart.c
index 696e4a2..6a9644d 100644
--- a/checkpoint/restart.c
+++ b/checkpoint/restart.c
@@ -323,6 +323,7 @@ int _ckpt_read_obj_type(struct ckpt_ctx *ctx, void *ptr, int len, int type)
 		return -EINVAL;
 	return h.len - sizeof(h);
 }
+EXPORT_SYMBOL(_ckpt_read_obj_type);
 
 /**
  * _ckpt_read_buffer - read an object of type buffer (set length)
@@ -339,6 +340,7 @@ int _ckpt_read_buffer(struct ckpt_ctx *ctx, void *ptr, int len)
 	BUG_ON(!len);
 	return _ckpt_read_obj_type(ctx, ptr, len, CKPT_HDR_BUFFER);
 }
+EXPORT_SYMBOL(_ckpt_read_buffer);
 
 /**
  * _ckpt_read_string - read an object of type string (set length)
@@ -360,6 +362,7 @@ int _ckpt_read_string(struct ckpt_ctx *ctx, void *ptr, int len)
 		((char *) ptr)[len - 1] = '\0';	/* always play it safe */
 	return 0;
 }
+EXPORT_SYMBOL(_ckpt_read_string);
 
 /**
  * ckpt_read_obj - allocate and read an object (ckpt_hdr followed by payload)
@@ -430,6 +433,7 @@ void *ckpt_read_obj_type(struct ckpt_ctx *ctx, int len, int type)
 
 	return h;
 }
+EXPORT_SYMBOL(ckpt_read_obj_type);
 
 /**
  * ckpt_read_buf_type - allocate and read an object of some type (flxible)
@@ -464,6 +468,7 @@ void *ckpt_read_buf_type(struct ckpt_ctx *ctx, int max, int type)
 
 	return h;
 }
+EXPORT_SYMBOL(ckpt_read_buf_type);
 
 /**
  * ckpt_read_payload - allocate and read the payload of an object
@@ -499,6 +504,7 @@ int ckpt_read_payload(struct ckpt_ctx *ctx, void **ptr, int max, int type)
 
 	return len;
 }
+EXPORT_SYMBOL(ckpt_read_payload);
 
 /**
  * ckpt_read_string - allocate and read a string (variable length)
@@ -518,6 +524,7 @@ char *ckpt_read_string(struct ckpt_ctx *ctx, int max)
 	str[len - 1] = '\0';  	/* always play it safe */
 	return str;
 }
+EXPORT_SYMBOL(ckpt_read_string);
 
 /**
  * ckpt_read_consume - consume the next object of expected type
@@ -544,6 +551,7 @@ int ckpt_read_consume(struct ckpt_ctx *ctx, int len, int type)
 	ckpt_hdr_put(ctx, h);
 	return ret;
 }
+EXPORT_SYMBOL(ckpt_read_consume);
 
 /***********************************************************************
  * Restart
diff --git a/checkpoint/sys.c b/checkpoint/sys.c
index fe85ca7..9e9df9b 100644
--- a/checkpoint/sys.c
+++ b/checkpoint/sys.c
@@ -130,6 +130,7 @@ void *ckpt_hdr_get(struct ckpt_ctx *ctx, int len)
 {
 	return kzalloc(len, GFP_KERNEL);
 }
+EXPORT_SYMBOL(ckpt_hdr_get);
 
 /**
  * _ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
@@ -143,6 +144,7 @@ void _ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr, int len)
 {
 	kfree(ptr);
 }
+EXPORT_SYMBOL(_ckpt_hdr_put);
 
 /**
  * ckpt_hdr_put - free a hdr allocated with ckpt_hdr_get
@@ -156,6 +158,7 @@ void ckpt_hdr_put(struct ckpt_ctx *ctx, void *ptr)
 	struct ckpt_hdr *h = (struct ckpt_hdr *) ptr;
 	_ckpt_hdr_put(ctx, ptr, h->len);
 }
+EXPORT_SYMBOL(ckpt_hdr_put);
 
 /**
  * ckpt_hdr_get_type - get a hdr of certain size
@@ -176,6 +179,7 @@ void *ckpt_hdr_get_type(struct ckpt_ctx *ctx, int len, int type)
 	h->len = len;
 	return h;
 }
+EXPORT_SYMBOL(ckpt_hdr_get_type);
 
 #define DUMMY_LSM_INFO "dummy"
 
@@ -547,6 +551,7 @@ void do_ckpt_msg(struct ckpt_ctx *ctx, int err, char *fmt, ...)
 	if (err)
 		ckpt_set_error(ctx, err);
 }
+EXPORT_SYMBOL(do_ckpt_msg);
 
 /**
  * walk_task_subtree: iterate through a task's descendants
@@ -698,6 +703,7 @@ long do_sys_restart(pid_t pid, int fd, unsigned long flags, int logfd)
 
 /* FIX: allow to change during runtime */
 unsigned long __read_mostly ckpt_debug_level = CKPT_DDEFAULT;
+EXPORT_SYMBOL(ckpt_debug_level);
 
 static __init int ckpt_debug_setup(char *s)
 {
-- 
1.6.3.3
