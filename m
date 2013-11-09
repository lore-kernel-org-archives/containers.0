From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [REVIEW][PATCH 1/2] userns: Better restrictions on when proc and
	sysfs can be mounted
Date: Fri, 08 Nov 2013 21:22:48 -0800
Message-ID: <87a9hejgif.fsf@xmission.com>
References: <878uzmhkqg.fsf@xmission.com> <52749663.2000701@cn.fujitsu.com>
	<CAE=NcrY+CzX+H4XQTdGj7CSZ98a5T=bNgT6=jGZzcjyaHb-ttw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CAE=NcrY+CzX+H4XQTdGj7CSZ98a5T=bNgT6=jGZzcjyaHb-ttw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Janne Karhunen's message of "Mon, 4 Nov 2013 09:00:39 +0200")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, Linux Containers <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
List-Id: containers.vger.kernel.org

Janne Karhunen <janne.karhunen-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:

> On Sat, Nov 2, 2013 at 8:06 AM, Gao feng <gaofeng-BthXqXjhjHXQFUHtdCDX3A@public.gmane.org> wrote:
>
>> And another question, it looks like if we don't have proc/sys fs mounted,
>> then proc/sys will be failed to be mounted?
>
> I have been wondering the same. Was quite some illogical surprise that
> we have to be doing overlay mounts. This is the exact opposite from what
> anyone would expect.

Before I address the question of bugs I will answer the question of
semantics.

In weird cases like chroot jails it is desirable not to mount /sys and /proc
and if root sets that policy it would be unfortunate if user namespaces
overrode the policy.  It limits what an attacker can accomplish.

So yes in the case of /proc and /sys the goal is to limit you to
functionality you could have had with bind mounts.

Eric
