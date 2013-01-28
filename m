From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [PATCH review 3/6] userns: Recommend use of memory control groups.
Date: Mon, 28 Jan 2013 00:05:57 -0800
Message-ID: <874ni1vije.fsf@xmission.com>
References: <87ehh8it9s.fsf@xmission.com> <87txq4hedl.fsf@xmission.com>
	<51062AB5.9060203@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51062AB5.9060203-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> (Lord Glauber Costa of Sealand's
	message of "Mon, 28 Jan 2013 11:37:25 +0400")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: containers.vger.kernel.org

Lord Glauber Costa of Sealand <glommer-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org> writes:

> On 01/26/2013 06:22 AM, Eric W. Biederman wrote:
>> 
>> In the help text describing user namespaces recommend use of memory
>> control groups.  In many cases memory control groups are the only
>> mechanism there is to limit how much memory a user who can create
>> user namespaces can use.
>> 
>> Signed-off-by: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
>> ---
>>  Documentation/namespaces/resource-control.txt |   10 ++++++++++
>>  init/Kconfig                                  |    7 +++++++
>>  2 files changed, 17 insertions(+), 0 deletions(-)
>>  create mode 100644 Documentation/namespaces/resource-control.txt
>> 
>> diff --git a/Documentation/namespaces/resource-control.txt b/Documentation/namespaces/resource-control.txt
>> new file mode 100644
>> index 0000000..3d8178a
>> --- /dev/null
>> +++ b/Documentation/namespaces/resource-control.txt
>> @@ -0,0 +1,10 @@
>> +There are a lot of kinds of objects in the kernel that don't have
>> +individual limits or that have limits that are ineffective when a set
>> +of processes is allowed to switch user ids.  With user namespaces
>> +enabled in a kernel for people who don't trust their users or their
>> +users programs to play nice this problems becomes more acute.
>> +
>> +Therefore it is recommended that memory control groups be enabled in
>> +kernels that enable user namespaces, and it is further recommended
>> +that userspace configure memory control groups to limit how much
>> +memory users they don't trust to play nice can use.
>> diff --git a/init/Kconfig b/init/Kconfig
>> index 7d30240..c8c58bd 100644
>> --- a/init/Kconfig
>> +++ b/init/Kconfig
>> @@ -1035,6 +1035,13 @@ config USER_NS
>>  	help
>>  	  This allows containers, i.e. vservers, to use user namespaces
>>  	  to provide different user info for different servers.
>> +
>> +	  When user namespaces are enabled in the kernel it is
>> +	  recommended that the MEMCG and MEMCG_KMEM options also be
>> +	  enabled and that user-space use the memory control groups to
>> +	  limit the amount of memory a memory unprivileged users can
>> +	  use.
>> +
>>  	  If unsure, say N.
>
> Since this becomes an official recommendation that people will likely
> follow, are we really that much concerned about the types of abuses the
> MEMCG_KMEM will prevent? Those are mostly metadata-based abuses users
> could do in their own local disks without mounting anything extra (and
> things that look like that)
>
> Unless there is a specific concern here, shouldn't we say "... that the
> MEMCG (and possibly MEMCG_KMEM) options..." ?

There are quite a few specific concerns.  The easiest to spot is
unshare(CLONE_NEWUSER), and the other namespaces.  Then there are
network devices.  Then there is I don't know what else.

Most distro's don't seem to care at all about limiting a users memory
so in that sense it is not a concern.

On the other hand for everyone who wants to limit a user's memory the
only way that is going to happen in a reasonable amount of
implementation time is with memory control groups, and slabs and kmalloc
are most definitely part of the memory needs to be limited.

Eric
