From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: [RFC][PATCH] Fix cap_capable to only allow owners in the parent
	user namespace to have caps.
Date: Fri, 14 Dec 2012 13:43:41 -0800
Message-ID: <87wqwkz4vm.fsf__25307.6706351296$1355521461$gmane$org@xmission.com>
References: <87ip88uw4n.fsf@xmission.com> <50CA2B55.5070402@amacapital.net>
	<87mwxhtxve.fsf@xmission.com> <87zk1hshk7.fsf_-_@xmission.com>
	<20121214032820.GA5115@mail.hallyn.com> <87bodxi9zw.fsf@xmission.com>
	<20121214152607.GA9266@mail.hallyn.com> <87bodwd4aw.fsf@xmission.com>
	<20121214161514.GA9962@mail.hallyn.com> <87r4ms5wpm.fsf@xmission.com>
	<CA+55aFw5CMf0-o=yDt2Rj-SYH4pfW1L9QbNb6uKHEdzAyYcvGQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <CA+55aFw5CMf0-o=yDt2Rj-SYH4pfW1L9QbNb6uKHEdzAyYcvGQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Linus Torvalds's message of "Fri, 14 Dec 2012 10:43:15 -0800")
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

> On Fri, Dec 14, 2012 at 10:12 AM, Eric W. Biederman
> <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org> wrote:
>>
>> That said Serge I think I have lost track of the point of your question.
>
> .. and I'm a bit unsure what I should do about this all. Including
> pulling the pull request that actually can make this all matter.
>
> Hmm? Any consensus?

It looks like we have consensus (baring the color of the shed)
of what the code should look like for v3.8.

From the most embarrassingly timed, but most useful review by Andy I have
4 fixes queued up in my development tree.

Fixing cap_capable to test for the parent namespace.
Fixing setns to require nsown_capable(CAP_SYS_ADMIN)
--
Fixing commit_creds to not clear task dumpable unnecessarily.
Fixing a typo in the description.

What I would like to do is to do is what I would if this was not the
middle of the merge window with changes like this.

Toss those patches out for last round of review.

Possibly toss the last two patches if there are any problems because
they are not necessary.

Put the patches in my for-next branch and have them sit in linux-next
for a day or three. 

Send you an updated pull request.


I am recovering from a cold so I am running slower than I would like
this week and would really rather not rush getting these patches out.

What I don't want to be is so cautious and careful that you decide to
pass on my pull request.  The code is harmless with user namespaces
disabled.  The code has been baking for a long time, some of it for much
too long and it is as solid as I think it will get out before being
merged.  Nor is the code complex Andy managed to dig and figure it all
out in about a day.

Linus does that work for you?

Eric
