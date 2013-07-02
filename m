From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: Interaction user namespace, /proc/1 ownership & cap_set
Date: Tue, 02 Jul 2013 01:44:49 -0700
Message-ID: <87wqp9uz9a.fsf@xmission.com>
References: <20130701161625.GQ15954@redhat.com>
	<51D261D3.3030002@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <51D261D3.3030002-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> (Gao feng's message of "Tue, 02
	Jul 2013 13:14:59 +0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org>
Cc: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Serge Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
List-Id: containers.vger.kernel.org

Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> writes:

> On 07/02/2013 12:16 AM, Daniel P. Berrange wrote:
>> I'm struggling debugging a strange problem with interaction between user
>> namespaces, cap_set and ownership of files in /proc/1/
>> 
>
> This problem is occured after we call setuid/gid.
>
> for example, a task whose pid is 1234 calls
> setregid(10,10);
> setreuid(10,10);
>
>
> The uid/gid of the /proc/1234 is 10:0
> ll /proc/1234 -d
> dr-xr-xr-x 8 uucp wheel 0 Jul  2 10:57 /proc/1234
>
> the uid/gid of the files under /proc/1234 are two kinds...
> ll /proc/1234
> dr-xr-xr-x 2 uucp wheel 0 Jul  2 10:58 attr
> -rw-r--r-- 1 root root 0 Jul  2 10:58 autogroup
> ...
> dr-xr-xr-x 5 uucp wheel 0 Jul  2 10:58 net
> dr-x--x--x 2 root root 0 Jul  2 10:58 ns
> ...
> dr-xr-xr-x 3 uucp wheel 0 Jul  2 10:58 task
>
> I checked the pre_revalidate and found the owner of the files under /proc/<pid>
> will be set to the GLOBAL_ROOT_UID if the task executed setuid/setgid(task_dumpable is false).
> Is this what we expected? why? 

Expected yes.  Perfect perhaps not.

That piece of code has not been examined to see if it is safe to use
make_kuid(task_user_ns(task), 0), instead of GLOBAL_ROOT_UID.

> For user namespace,the owner of /proc/1/* is incorrect and
> after task call setuid/gid in user namespace, the owner of /proc/<pid-of-this-task>/* is incorrect
> too.

From the current semantics of dumpable GLOBAL_ROOT_UID is correct.

Please double check but I believe /proc/self should continue to work,
despite this.

The practical question is there anything that can go wrong if we allow
the root of the user namespace of the process to read it.  Especially
since several permission changes can happen a process may stop being
dumpable before we enter the user namespace.  So it is not immediately
clear that relaxing the dumpable rules is safe.

Eric
