From: "Dmitry Adamushko" <dmitry.adamushko-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Re: Hang with fair cgroup scheduler (reproducer is attached.)
Date: Sun, 16 Dec 2007 01:00:07 +0100
Message-ID: <b647ffbd0712151600s14e3f355we5ee6348b4d484cc@mail.gmail.com>
References: <20071214141528.GA6161@linux.vnet.ibm.com>
	<b647ffbd0712140447kfba5945ybde40f18653dd164@mail.gmail.com>
	<20442799.1197642268756.kamezawa.hiroyu@jp.fujitsu.com>
	<20071214153607.GB23670@linux.vnet.ibm.com>
	<20071214153823.GC23670@linux.vnet.ibm.com>
	<b647ffbd0712140825h4f541be0xa7a7866e70b3af7a@mail.gmail.com>
	<b647ffbd0712141151k697d9bbemda9a7e90515e4400@mail.gmail.com>
	<Pine.LNX.4.58.0712141614340.22005@gandalf.stny.rr.com>
	<b647ffbd0712150222p30cac9f9i772c2a2c4e05a4a@mail.gmail.com>
	<b647ffbd0712151544n2dfad101r2d306d393e8550ff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1379_4789729.1197763207360"
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <b647ffbd0712151544n2dfad101r2d306d393e8550ff-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dhaval Giani <dhaval-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>, Srivatsa Vaddagiri <vatsa-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>, Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Ingo Molnar <mingo-X9Un+BFzKDI@public.gmane.org>
List-Id: containers.vger.kernel.org

------=_Part_1379_4789729.1197763207360
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

Dhaval,

so following the analysis in the previous mail... here is a test
patch. Could you please give it a try?

TIA,

(enclosed non white-space broken version)

---
--- a/kernel/sched.c
+++ b/kernel/sched.c
@@ -7360,7 +7360,7 @@ void sched_move_task(struct task_struct *tsk)

        update_rq_clock(rq);

-       running = task_running(rq, tsk);
+       running = (rq->curr == tsk);
        on_rq = tsk->se.on_rq;

        if (on_rq) {
---

-- 
Best regards,
Dmitry Adamushko

------=_Part_1379_4789729.1197763207360
Content-Type: text/x-patch; name=01-set_task_cfs_rq.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fa8t9izi
Content-Disposition: attachment; filename=01-set_task_cfs_rq.patch

ZGlmZiAtLWdpdCBhL2luY2x1ZGUvbGludXgvc2NoZWQuaCBiL2luY2x1ZGUvbGludXgvc2NoZWQu
aApkaWZmIC0tZ2l0IGEva2VybmVsL3NjaGVkLmMgYi9rZXJuZWwvc2NoZWQuYwppbmRleCBkYzZm
YjI0Li4xMmZmNjBmIDEwMDY0NAotLS0gYS9rZXJuZWwvc2NoZWQuYworKysgYi9rZXJuZWwvc2No
ZWQuYwpAQCAtNzM2MCw3ICs3MzYwLDcgQEAgdm9pZCBzY2hlZF9tb3ZlX3Rhc2soc3RydWN0IHRh
c2tfc3RydWN0ICp0c2spCiAKIAl1cGRhdGVfcnFfY2xvY2socnEpOwogCi0JcnVubmluZyA9IHRh
c2tfcnVubmluZyhycSwgdHNrKTsKKwlydW5uaW5nID0gKHJxLT5jdXJyID09IHRzayk7CiAJb25f
cnEgPSB0c2stPnNlLm9uX3JxOwogCiAJaWYgKG9uX3JxKSB7CmRpZmYgLS1naXQgYS9rZXJuZWwv
c2NoZWRfZmFpci5jIGIva2VybmVsL3NjaGVkX2ZhaXIuYwo=
------=_Part_1379_4789729.1197763207360
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
Containers mailing list
Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
https://lists.linux-foundation.org/mailman/listinfo/containers
------=_Part_1379_4789729.1197763207360--
