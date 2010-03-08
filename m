From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: [RFC][PATCH] ns: Syscalls for better namespace sharing control.
Date: Mon, 8 Mar 2010 11:47:07 -0600
Message-ID: <20100308174707.GA13929__24893.7590433799$1268070488$gmane$org@us.ibm.com>
References: <4B8E9370.3050300@parallels.com> <m17hptjh3m.fsf@fess.ebiederm.org>
	<4B9158F5.5040205@parallels.com> <m1vdda1pmx.fsf@fess.ebiederm.org>
	<4B926B1B.5070207@free.fr> <m1aaulyy5c.fsf@fess.ebiederm.org>
	<4B92C886.9020507@free.fr> <m1fx4bxlfy.fsf@fess.ebiederm.org>
	<20100308170719.GD6399@us.ibm.com>
	<m1pr3eu36u.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1pr3eu36u.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Netfilter Development Mailinglist <netfilter-devel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Ben Greear <greearb-my8/4N5VtI7c+919tysfdA@public.gmane.org>, Sukadev Bhattiprolu <sukadev-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> 
> >> I have take an snapshot of my development tree and placed it at.
> >> 
> >> 
> >> git://git.kernel.org/pub/scm/linux/people/ebiederm/linux-2.6.33-nsfd-v5.git
> >> 
> >> 
> >> >> I am going to explore a bit more.  Given that nsfd is using the same
> >> >> permission checks as a proc file, I think I can just make it a proc
> >> >> file.  Something like "/proc/<pid>/ns/net".  With a little luck that
> >> >> won't suck too badly.
> >> >>   
> >> > Ah ! yes. Good idea.
> >> 
> >> It is a hair more code to use proc files but nothing worth counting.
> >> 
> >> Probably the biggest thing I am aware of right now in my development
> >> tree is in getting uids to pass properly between unix domain sockets
> >> I would up writing this cred_to_ucred function.
> >> 
> >> Serge can you take a look and check my logic, and do you have
> >> any idea of where we should place something like pid_vnr but
> >> for the uid namespace?
> >
> > Well my first thought was user_namespace, but I'm thinking kernel/cred.c is
> > the best place for it.
> 
> Thanks.
> 
> >> void cred_to_ucred(struct pid *pid, const struct cred *cred,
> >> 		   struct ucred *ucred)
> >> {
> >> 	ucred->pid = pid_vnr(pid);
> >> 	ucred->uid = ucred->gid = -1;
> >> 	if (cred) {
> >> 		struct user_namespace *cred_ns = cred->user->user_ns;
> >> 		struct user_namespace *current_ns = current_user_ns();
> >> 		struct user_namespace *tmp;
> >> 
> >> 		if (likely(cred_ns == current_ns)) {
> >> 			ucred->uid = cred->euid;
> >> 			ucred->gid = cred->egid;
> >> 		} else {
> >> 			/* Is cred in a child user namespace */
> >> 			tmp = cred_ns;
> >> 			do {
> >> 				tmp = tmp->creator->user_ns;
> >> 				if (tmp == current_ns) {
> >
> > 	Hmm, I think you want to catch one level up - so the creator itself
> > 	is in current_user_ns, so
> 
> >
> > 	do {
> > 		if (tmp->creator->user_ns == current_ns) {
> > 			ucred->uid = tmp->creator->uid;
> > 			ucred->gid = tmp->creator_gid;
> > 			return;
> > 		}
> > 		tmp = tmp->creator->user_ns;
> > 	} while (tmp != &init_user_ns);
> 
> Good catch.  
> 
> >> 					ucred->uid = tmp->creator->uid;
> >> 					ucred->gid = overflowgid;
> >
> > 			should we start recording a user_ns->creator_gid
> > 			instead?
> 
> I had a similar question.  Possibly we can just grab the creators cred.

Oh, yeah, make user_ns->creator a cred, excellent idea - then we have
the LSM and capability fields cached as well.

-serge
