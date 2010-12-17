From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC 1/5] user namespaces: Add a user_namespace as creator/owner
	of uts_namespace
Date: Fri, 17 Dec 2010 11:26:50 -0800
Message-ID: <m18vzoryit.fsf__2892.20298077471$1292614070$gmane$org@fess.ebiederm.org>
References: <20101217152246.GA8221@mail.hallyn.com>
	<20101217152458.GA11162@mail.hallyn.com>
	<20101217173125.GA29982@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20101217173125.GA29982-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> (Greg KH's message of "Fri, 17
	Dec 2010 09:31:25 -0800")
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Michael Kerrisk <michael.kerrisk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, kernel list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, LSM <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Kees Cook <kees.cook-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
List-Id: containers.vger.kernel.org

Greg KH <greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org> writes:

> On Fri, Dec 17, 2010 at 03:24:58PM +0000, Serge E. Hallyn wrote:
>> copy_process() handles CLONE_NEWUSER before the rest of the
>> namespaces.  So in the case of clone(CLONE_NEWUSER|CLONE_NEWUTS)
>> the new uts namespace will have the new user namespace as its
>> owner.  That is what we want, since we want root in that new
>> userns to be able to have privilege over it.
>> 
>> Signed-off-by: Serge E. Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> ---
>>  include/linux/utsname.h |    3 +++
>>  init/version.c          |    2 ++
>>  kernel/nsproxy.c        |    3 +++
>>  kernel/user.c           |    8 ++++++--
>>  kernel/utsname.c        |    4 ++++
>>  5 files changed, 18 insertions(+), 2 deletions(-)
>> 
>> diff --git a/include/linux/utsname.h b/include/linux/utsname.h
>> index 69f3997..85171be 100644
>> --- a/include/linux/utsname.h
>> +++ b/include/linux/utsname.h
>> @@ -37,9 +37,12 @@ struct new_utsname {
>>  #include <linux/nsproxy.h>
>>  #include <linux/err.h>
>>  
>> +struct user_namespace;
>> +
>>  struct uts_namespace {
>>  	struct kref kref;
>>  	struct new_utsname name;
>> +	struct user_namespace *user_ns;
>>  };
>>  extern struct uts_namespace init_uts_ns;
>>  
>> diff --git a/init/version.c b/init/version.c
>> index 79fb8c2..9eb19fb 100644
>> --- a/init/version.c
>> +++ b/init/version.c
>> @@ -21,6 +21,7 @@ extern int version_string(LINUX_VERSION_CODE);
>>  int version_string(LINUX_VERSION_CODE);
>>  #endif
>>  
>> +extern struct user_namespace init_user_ns;
>>  struct uts_namespace init_uts_ns = {
>>  	.kref = {
>>  		.refcount	= ATOMIC_INIT(2),
>
> Wait, WTF?
>
> You have a static kref and you try to automatically instanciate it here?
> As it's static, why are you even having a kref at all, what good does it
> do you, you can't delete the thing, it's always around, so just remove
> it entirely please.
>
> Or, dynamically create it properly.  In other words, this is majorly
> broken.

There is a very weird case for the data structures the initial task has
references to.  The initial task never goes away and so those data
structure never go away.  Furthermore we need many of those data
structures before we have a memory allocator ready.  So we statically
allocate a single data structure and up it's reference count to ensure
that the count never goes to zero.

There are also major benefits to have the version of something that is
never freed never going away, because it means you can just reference it
in code.  So while I would be happy to say this is special don't use a
kref and roll the reference counting logic by hand, we aren't
dynamically allocating init_uts_ns any time soon.

Eric
