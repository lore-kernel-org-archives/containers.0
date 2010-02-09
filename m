From: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Supporting patches for netns/netdev (v2)
Date: Tue, 09 Feb 2010 14:10:18 -0800
Message-ID: <87y6j2giwl.fsf@caffeine.danplanet.com>
References: <1265749870-13989-1-git-send-email-danms@us.ibm.com>
	<4B71DC2B.1070107@cs.columbia.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4B71DC2B.1070107-eQaUEPhvms7ENvBUuze7eA@public.gmane.org> (Oren Laadan's message of
	"Tue\, 09 Feb 2010 17\:05\:31 -0500")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Oren Laadan <orenl-eQaUEPhvms7ENvBUuze7eA@public.gmane.org>
Cc: containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org
List-Id: containers.vger.kernel.org

OL> Both look good.

Okay, but per Serge's suggestion shall we change the restore_obj() to
the one included below? :)

-- 
Dan Smith
IBM Linux Technology Center
email: danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org

commit d0c71c159decd47c4a6f9778d02dc521b74ff414
Author: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Date:   Tue Feb 9 14:04:23 2010 -0800

    Make restore_obj() tolerate a preexisting object in the hash (v2)
    
    ... as long as the pointer is the same as that returned from the restore
    function.  Also move the compulsory ref_drop() so that it only gets
    done if we created the new object.
    
    The existing object tolerance is important for netdev restore because it
    means that I can refer to a peer by its objref instead of needing the
    (previously-rejected) veth_peer() function.  If this is not acceptable,
    then I'll need to keep a separate list of pairs.
    
    Changes in v2:
     - Check that the type of the object already in the hash matches that
       of the objref header we're reading.
     - Add a comment about why and how we might get into this sort of
       situation.
    
    Signed-off-by: Dan Smith <danms-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>

diff --git a/checkpoint/objhash.c b/checkpoint/objhash.c
index 0b06b06..4ca7799 100644
--- a/checkpoint/objhash.c
+++ b/checkpoint/objhash.c
@@ -1059,16 +1059,29 @@ int restore_obj(struct ckpt_ctx *ctx, struct ckpt_hdr_ob
        if (IS_ERR(ptr))
                return PTR_ERR(ptr);
 
-       if (obj_find_by_objref(ctx, h->objref))
-               obj = ERR_PTR(-EINVAL);
-       else
+       obj = obj_find_by_objref(ctx, h->objref);
+       if (!obj) {
                obj = obj_new(ctx, ptr, h->objref, h->objtype);
-       /*
-        * Drop an extra reference to the object returned by ops->restore:
-        * On success, this clears the extra reference taken by obj_new(),
-        * and on failure, this cleans up the object itself.
-        */
-       ops->ref_drop(ptr, 0);
+               /*
+                * Drop an extra reference to the object returned by
+                * ops->restore: On success, this clears the extra
+                * reference taken by obj_new(), and on failure, this
+                * cleans up the object itself.
+                */
+               ops->ref_drop(ptr, 0);
+       } else if ((obj->ptr != ptr) || (obj->ops->obj_type != h->objtype)) {
+               /* Normally, we expect an object to not already exist
+                * in the hash.  However, for some special scenarios
+                * where we're restoring sets of objects that must be
+                * co-allocated (such, as veth netdev pairs) we need
+                * to tolerate this case if the second restore returns
+                * the correct type and pointer, as specified in the
+                * existing object.  If either of those don't match,
+                * we fail.
+                */
+               obj = ERR_PTR(-EINVAL);
+       }
+
        if (IS_ERR(obj)) {
                ops->ref_drop(ptr, 1);
                return PTR_ERR(obj);
