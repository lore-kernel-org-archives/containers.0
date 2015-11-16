From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] locks: Allow disabling mandatory locking at compile
	time
Date: Mon, 16 Nov 2015 15:34:18 -0600
Message-ID: <874mglljc5.fsf__10353.1153210954$1447710284$gmane$org@x220.int.ebiederm.org>
References: <876118v333.fsf@x220.int.ebiederm.org>
	<20151111202607.GD29410@fieldses.org>
	<20151111174401.5778153c@tlielax.poochiereds.net>
	<876118ruiu.fsf@x220.int.ebiederm.org>
	<20151116095841.0f620a5c@tlielax.poochiereds.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20151116095841.0f620a5c-9yPaYZwiELC+kQycOl6kW4xkIHaj4LzF@public.gmane.org> (Jeff Layton's
	message of "Mon, 16 Nov 2015 09:58:41 -0500")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org>
Cc: "J. Bruce Fields" <bfields-uC3wQj2KruNg9hUCZPvPmw@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Benjamin Coddington <bcodding-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Dmitry Vyukov <dvyukov-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Jeff Layton <jeff.layton-7I+n7zu2hftEKMMhf/gKZA@public.gmane.org> writes:

>> Given the general concensus of this thread it looks like we will also
>> want this incremental patch to deal with the user namespace case.
>> 
>> From: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> Date: Wed, 11 Nov 2015 17:18:07 -0600
>> Subject: [PATCH] locks: Don't allow mounts in user namespaces to enable mandatory locking
>> 
>> Since no one uses mandatory locking and files with mandatory locks can
>> cause problems don't allow them in user namespaces.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  fs/namespace.c | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>> 
>> diff --git a/fs/namespace.c b/fs/namespace.c
>> index dee44b4791f0..95a349d5003d 100644
>> --- a/fs/namespace.c
>> +++ b/fs/namespace.c
>> @@ -1589,7 +1589,7 @@ static inline bool may_mandlock(void)
>>  #ifndef	CONFIG_MANDATORY_FILE_LOCKING
>>  	return false;
>>  #endif
>> -	return true;
>> +	return capable(CAP_SYS_ADMIN);
>>  }
>>  
>>  /*
>
> Fair enough. I'll merge that as well and we'll see what breaks.

Sounds good.  If something breaks just revert this bit.

The ways things work today is not an issue if people are actually using
mandatory file locking.


The fundamental issues that triggered my looking into this was a single
threaded server that accepts input from unprivileged users and hangs if
reading that input takes too long.  Mandatory locking just made it
easier to supply an input that hangs.

There are a countless other ways to make reading lots of data from a
file descriptor slow, the obvious ones being cpu load, disk load (for
local filesystems), and network load (for network filesystems).

Passing file descriptors appears to be the only path where mandatory
locking from files in a user namespace can affect processes outside of
the user namespace.  Given that there are many other ways to trigger a
slow file descriptor, that mandatory locking problems are easy to avoid,
I just can not see the existing kernel behavior as being wrong.

The current state of affairs is a problem in that we have a feature in
the kernel that apparently no one uses and everyone ignores.   Turning
off the feature is the right solution for that.

There is a privileged operation involved with enabling "-o mand" on
a filesystem.  The intent and the only value I can see in the "-o mand"
flag is that it determines if a filesystem will interpret the a specific
combinationation of file mode bits as specifying mandatory locking on a
file.  Allowing that on files accessible only to users inside of the user
namespace will not cause problems for the rest of the system except
potentially with passed file descriptors.

Eric
