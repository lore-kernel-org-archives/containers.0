From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/2] userns: Better restrictions on when proc and
	sysfs can be mounted
Date: Sat, 31 Aug 2013 21:45:11 -0700
Message-ID: <87eh99noa0.fsf__41085.5516246103$1378010734$gmane$org@xmission.com>
References: <878uzmhkqg.fsf@xmission.com>
	<CALCETrWPDzuoaJp2ko5jAbwYUBqSdPjvO5uGo-gZVsS4Wm1PKQ@mail.gmail.com>
	<87a9k2g5la.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <87a9k2g5la.fsf-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> (Eric W. Biederman's message of
	"Tue, 27 Aug 2013 14:57:05 -0700")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Cc: Linux FS Devel <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman) writes:

> Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> writes:
>
>> On Tue, Aug 27, 2013 at 2:44 PM, Eric W. Biederman
>> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>>
>>> Rely on the fact that another flavor of the filesystem is already
>>> mounted and do not rely on state in the user namespace.
>>
>> Possibly dumb question: does this check whether the pre-existing mount
>> has hidepid set?
>
> Not currently. 
>
> It may be worth doing something with respect to hidepid.  I forget what
> hidepid tries to do, and I need to dash.  But feel free to cook up a
> follow on patch.

So I have thought about this a bit more.

hidepid hides the processes that ptrace_may_access will fail on.

You can only reach the point where an unprivileged mount of a pid
namespace is possible if you have created both a user namespace and a
pid namespace.  Which means the creator of the pid namespace will be
capable of ptracing all of the other processes in the pid namespace
(ignoring setns).

So I don't see a point of worry about hidepid or the hidepid gid on
child pid namespaces.  The cases it is attempting to protecting against
really don't exist.

Eric
