From: "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH 16/43] userns: Simplify the user_namespace by making
	userns->creator a kuid.
Date: Tue, 24 Apr 2012 20:23:01 +0000
Message-ID: <20120424202301.GA11326@mail.hallyn.com>
References: <m11unyn70b.fsf@fess.ebiederm.org>
	<1333862139-31737-16-git-send-email-ebiederm@xmission.com>
	<20120418184847.GA4984@mail.hallyn.com>
	<m1aa266meh.fsf@fess.ebiederm.org>
	<20120424173347.GA14017@mail.hallyn.com>
	<m14ns8lxyc.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m14ns8lxyc.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Cyrill Gorcunov <gorcunov-GEFAQzZX7r8dnm+yROfE0A@public.gmane.org>, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
List-Id: containers.vger.kernel.org

Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> 
> > Quoting Eric W. Biederman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> "Serge E. Hallyn" <serge-A9i7LUbDfNHQT0dZR+AlfA@public.gmane.org> writes:
> >> 
> >> > Quoting Eric W. Beiderman (ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org):
> >> >> From: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> >> 
> >> >> - Transform userns->creator from a user_struct reference to a simple
> >> >>   kuid_t, kgid_t pair.
> >> >> 
> >> >>   In cap_capable this allows the check to see if we are the creator of
> >> >>   a namespace to become the classic suser style euid permission check.
> >> >> 
> >> >>   This allows us to remove the need for a struct cred in the mapping
> >> >>   functions and still be able to dispaly the user namespace creators
> >> >>   uid and gid as 0.
> >> >> 
> >> >> - Remove the now unnecessary delayed_work in free_user_ns.
> >> >> 
> >> >>   All that is left for free_user_ns to do is to call kmem_cache_free
> >> >>   and put_user_ns.  Those functions can be called in any context
> >> >>   so call them directly from free_user_ns removing the need for delayed work.
> >> >> 
> >> >> Signed-off-by: Eric W. Biederman <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> >> >> ---
> >> >>  include/linux/user_namespace.h |    4 ++--
> >> >>  kernel/user.c                  |    7 ++++---
> >> >>  kernel/user_namespace.c        |   39 ++++++++++++++++++---------------------
> >> >>  security/commoncap.c           |    5 +++--
> >> >>  4 files changed, 27 insertions(+), 28 deletions(-)
> >> >> 
> >> >> diff --git a/include/linux/user_namespace.h b/include/linux/user_namespace.h
> >> >> index d767508..8a391bd 100644
> >> >> --- a/include/linux/user_namespace.h
> >> >> +++ b/include/linux/user_namespace.h
> >> >> @@ -9,8 +9,8 @@
> >> >>  struct user_namespace {
> >> >>  	struct kref		kref;
> >> >>  	struct user_namespace	*parent;
> >> >> -	struct user_struct	*creator;
> >> >> -	struct work_struct	destroyer;
> >> >> +	kuid_t			owner;
> >> >> +	kgid_t			group;
> >> >>  };
> >> >>  
> >> >>  extern struct user_namespace init_user_ns;
> >> >> diff --git a/kernel/user.c b/kernel/user.c
> >> >> index 025077e..cff3856 100644
> >> >> --- a/kernel/user.c
> >> >> +++ b/kernel/user.c
> >> >> @@ -25,7 +25,8 @@ struct user_namespace init_user_ns = {
> >> >>  	.kref = {
> >> >>  		.refcount	= ATOMIC_INIT(3),
> >> >>  	},
> >> >> -	.creator = &root_user,
> >> >> +	.owner = GLOBAL_ROOT_UID,
> >> >> +	.group = GLOBAL_ROOT_GID,
> >> >>  };
> >> >>  EXPORT_SYMBOL_GPL(init_user_ns);
> >> >>  
> >> >> @@ -54,9 +55,9 @@ struct hlist_head uidhash_table[UIDHASH_SZ];
> >> >>   */
> >> >>  static DEFINE_SPINLOCK(uidhash_lock);
> >> >>  
> >> >> -/* root_user.__count is 2, 1 for init task cred, 1 for init_user_ns->user_ns */
> >> >> +/* root_user.__count is 1, for init task cred */
> >> >>  struct user_struct root_user = {
> >> >> -	.__count	= ATOMIC_INIT(2),
> >> >> +	.__count	= ATOMIC_INIT(1),
> >> >>  	.processes	= ATOMIC_INIT(1),
> >> >>  	.files		= ATOMIC_INIT(0),
> >> >>  	.sigpending	= ATOMIC_INIT(0),
> >> >> diff --git a/kernel/user_namespace.c b/kernel/user_namespace.c
> >> >> index 898e973..f69741a 100644
> >> >> --- a/kernel/user_namespace.c
> >> >> +++ b/kernel/user_namespace.c
> >> >> @@ -27,6 +27,16 @@ int create_user_ns(struct cred *new)
> >> >>  {
> >> >>  	struct user_namespace *ns, *parent_ns = new->user_ns;
> >> >>  	struct user_struct *root_user;
> >> >> +	kuid_t owner = make_kuid(new->user_ns, new->euid);
> >> >> +	kgid_t group = make_kgid(new->user_ns, new->egid);
> >> >> +
> >> >> +	/* The creator needs a mapping in the parent user namespace
> >> >> +	 * or else we won't be able to reasonably tell userspace who
> >> >> +	 * created a user_namespace.
> >> >> +	 */
> >> >> +	if (!kuid_has_mapping(parent_ns, owner) ||
> >> >> +	    !kgid_has_mapping(parent_ns, group))
> >> >> +		return -EPERM;
> >> >>  
> >> >>  	ns = kmem_cache_alloc(user_ns_cachep, GFP_KERNEL);
> >> >>  	if (!ns)
> >> >> @@ -43,7 +53,9 @@ int create_user_ns(struct cred *new)
> >> >>  
> >> >>  	/* set the new root user in the credentials under preparation */
> >> >>  	ns->parent = parent_ns;
> >> >
> >> > I think in the past the creator cred pinned the ns->parent.  Do you now
> >> > need to explicitly pin ns->parent (and release it in free_user_ns())?
> >> 
> >> Yes we do have to explicitly reference count the parent namespace.
> >> But that happened in the patch 7:
> >> "userns: Add an explicit reference to the parent user namespace"
> 
> Make that patch 8 not patch 7: 
> "userns: Add an explicit reference to the parent user namespace"
> Perhaps the patch number reference pointed you to look at the wrong code.

D'oh, yup.  That explains it better.

And so parent_userns keeps the refcount from the cred 'new' after
new->ns = ns;  That works, thanks.

> > Perhaps that suffices, but I'm not convinced.  The struct cred is
> > pinning it's own ns, but if t1 does clone(CLONE_NEWUSER) to produce
> > t2, which does the same to procduce t3, and then t2 exits, I'm not
> > seeing what will pin t2's userns.
> 
> t3's userns hold's a reference to the departed t2's userns.
> t2's userns hold's a reference to t1's userns.
> 
> free_user_ns does put that userns reference.
> 
> It is all there and explict.  Usernamespaces refer directly to each

Actually can we make it just one tinge more explicit, and put a comment
above the 'new->user_ns = ns'?  There's currently the comment

   /* Leave the reference to our user_ns with the new cred */

But that's about the initial refcount on the new ns.  Perhaps change that to:

   /*
    * Leave the reference to our new user_ns with the new cred,
    * and leave the reference on the old ns to pin new->parent_ns
    */

> other.  That was all needed to get struct user out of the usernamespace
> game.
> 
> Eric

Thanks, Eric.  So then

Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>

which, given the other nits are addressed, should cover the whole
set with my acks.

thanks,
-serge
