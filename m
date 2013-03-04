From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH 2/2] fs: Limit sys_mount to only request filesystem
	modules.
Date: Mon, 04 Mar 2013 10:36:01 -0800
Message-ID: <87y5e3dnce.fsf__48494.7626748637$1362422209$gmane$org@xmission.com>
References: <CAGXu5jK7x+gFKgCN5=ZF+kSc4xSNbGtSERHCoOnCEgiJ1_wNGg@mail.gmail.com>
	<20130303005700.GA32213@austin.hallyn.com>
	<874ngtxgt5.fsf@xmission.com>
	<CAGXu5j+bwUx6r++ttvYg4yJrUUHxoQ86tQ0JzEBoQQU6KAh9ww@mail.gmail.com>
	<874ngsrvrh.fsf@xmission.com>
	<CAGXu5jJiO=BmjVbpVJhxHbafn5T_SQbe5g-RLxRbmknNnQMyfQ@mail.gmail.com>
	<87k3pnmwpk.fsf_-_@xmission.com> <878v63mwm3.fsf_-_@xmission.com>
	<20130304173611.GA8500@cachalot>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20130304173611.GA8500@cachalot> (Vasily Kulikov's message of
	"Mon, 4 Mar 2013 21:36:11 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Cc: Brad Spengler <spender-JNS0hek0TMl4qEwOxq4T+Q@public.gmane.org>, kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, PaX Team <pageexec-Y8qEzhMunLyT9ig0jae3mg@public.gmane.org>, Al Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>, Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Dave Jones <davej-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Vasily Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org> writes:

> (cc'ed kernel-hardening)
>
> On Sun, Mar 03, 2013 at 23:51 -0800, Eric W. Biederman wrote:
>> Modify the request_module to prefix the file system type with "fs-"
>> and add aliases to all of the filesystems that can be built as modules
>> to match.
>> 
>> A common practice is to build all of the kernel code and leave code
>> that is not commonly needed as modules, with the result that many
>> users are exposed to any bug anywhere in the kernel.
>> 
>> Looking for filesystems with a fs- prefix limits the pool of possible
>> modules that can be loaded by mount to just filesystems trivially
>> making things safer with no real cost.
>> 
>> Using aliases means user space can control the policy of which
>> filesystem modules are auto-loaded by editing /etc/modprobe.d/*.conf
>> with blacklist and alias directives.  Allowing simple, safe,
>> well understood work-arounds to known problematic software.
>> 
>> This also addresses a rare but unfortunate problem where the filesystem
>> name is not the same as it's module name and module auto-loading
>> would not work.  While writing this patch I saw a handful of such
>> cases.  The most significant being autofs that lives in the module
>> autofs4.
>> 
>> This is relevant to user namespaces because we can reach the request
>> module in get_fs_type() without having any special permissions, and
>> people get uncomfortable when a user specified string (in this case
>> the filesystem type) goes all of the way to request_module.
>> 
>> After having looked at this issue I don't think there is any
>> particular reason to perform any filtering or permission checks beyond
>> making it clear in the module request that we want a filesystem
>> module.  The common pattern in the kernel is to call request_module()
>> without regards to the users permissions.  In general all a filesystem
>> module does once loaded is call register_filesystem() and go to sleep.
>> Which means there is not much attack surface exposed by loading a
>> filesytem module unless the filesystem is mounted.  In a user
>> namespace filesystems are not mounted unless .fs_flags = FS_USERNS_MOUNT,
>> which most filesystems do not set today.
>> 
>> Acked-by: Serge Hallyn <serge.hallyn-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
>> Acked-by: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
>> Reported-by: Kees Cook <keescook-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
> ...
>> diff --git a/fs/filesystems.c b/fs/filesystems.c
>> index da165f6..92567d9 100644
>> --- a/fs/filesystems.c
>> +++ b/fs/filesystems.c
>> @@ -273,7 +273,7 @@ struct file_system_type *get_fs_type(const char *name)
>>  	int len = dot ? dot - name : strlen(name);
>>  
>>  	fs = __get_fs_type(name, len);
>> -	if (!fs && (request_module("%.*s", len, name) == 0))
>> +	if (!fs && (request_module("fs-%.*s", len, name) == 0))
>>  		fs = __get_fs_type(name, len);
>>  
>>  	if (dot && fs && !(fs->fs_flags & FS_HAS_SUBTYPE)) {
>
> Maybe we should divide request_module() into several functions regarding
> expected caller's privileges?
>
> - request_module() for CAP_SYS_MODULE in init_ns
> - request_module_relaxed() for everybody
>
> request_module_relaxed() is used in get_fs_type(), dev_load() and all
> places where the safety of module loading is manually checked.  All old
> not yet checked users of request_module() will not be triggerable from user_ns.
> That's the same scheme as with capable() and ns_capable().

User namespaces in this discussion are pretty much a red-herring.  You
can already reach most request_module callers without having any
capabilities.  And honestly that seems fine.

It never ever hurts to request a module.

It only sometimes when something else has already gone wrong hurts to
get the module.

It makes sense to add a prefix when sending the module request to make
it clear what kind of module we are looking for.  That makes it easy to
tell why we are requesting the module and makes it easy to implement
policy controls in userspace.

I don't see any reason to limit request_module to people with some
capability or other.  The filesystem module_request just happened to be
after a capable(CAP_SYS_AMDIN) in this case which is the case people
noticed was a little fishy.

But if I have overlooked something I am happy to hear it.

Eric
