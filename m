From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the parent
	user namespace to have caps.
Date: Thu, 13 Dec 2012 14:55:42 -0800
Message-ID: <87zk1hr28h.fsf__36643.5674288825$1355439369$gmane$org@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
	<CA+55aFwXnFEFXbkwFPq9xt30xp2_6jfpBLd3E2bms79KKK=V1Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+55aFwXnFEFXbkwFPq9xt30xp2_6jfpBLd3E2bms79KKK=V1Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Linus Torvalds's message of "Thu, 13 Dec 2012 14:43:36 -0800")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Cc: LSM List <linux-security-module-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>, Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
List-Id: containers.vger.kernel.org

Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org> writes:

> On Thu, Dec 13, 2012 at 2:39 PM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> Andy Lutomirski pointed out that the current behavior of allowing the
>> owner of a user namespace to have all caps when that owner is not in a
>> parent user namespace is wrong.
>>
>> This is a bug introduced by the kuid conversion which made it possible
>> for the owner of a user namespace to live in a child user namespace.  I
>> goofed and totally missed this implication.
>
> Hmm. Shouldn't this be cc: stable if it was introduced in the kuid
> conversion? Or is it only an issue with your new namespace tree (which
> I haven't pulled yet)?

It should be CC stable.

I think I have fixed the bug I am hoping to get a second pair of eyeballs
before I send the patch officially.

The test for &init_user_ns keeps the bugs from affecting kernels with user
namespaces disabled.

The bug exists in 3.5 and 3.6 but barely matters because you can't
enable user namespaces without additional patches.

The bug exists in 3.7 but is should be of limited affect because
distributions are likely to prefer enabling nfs and fuse over user
namespaces.

I am going to step away for about an hour or so and then with hopefully
fresh eyes myself work to push the good version.  

Eric
