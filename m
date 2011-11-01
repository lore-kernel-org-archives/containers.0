From: ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org (Eric W. Biederman)
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Tue, 01 Nov 2011 10:17:05 -0700
Message-ID: <m1hb2nsqy6.fsf@fess.ebiederm.org>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
	<m1r51swmun.fsf@fess.ebiederm.org>
	<20111101043201.GA14734@faui40p.informatik.uni-erlangen.de>
	<m1lis0vxu6.fsf@fess.ebiederm.org>
	<20111101152624.GB14734@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111101152624.GB14734-+4JsuViRYHWM0MU9lROt9PpTrGXM5HoexJJUWDj/nkeELgA04lAiVw@public.gmane.org>
	(Toerless Eckert's message of "Tue, 1 Nov 2011 16:26:24 +0100")
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org> writes:

> THanks for replying,
>
> Sorry for asking what probably are a lot of naive questions, my excuse is
> that the documentation is somewhat scattered/incomplete ? ;-))
>
> I am trying to figure out how to minimize the virtualization to just the network
> name space and instantiate it in a lightweight fashion that can easily
> be counterfitted into some existing system. 
>
> What i would like to have is some simple program like "run-ns XXXX <program> <args>"
> that would run program <args> within namespace XXXX.
>
> So i was looking for some system call like set_ns(XXXX), but it seems there
> is no API like that. Instead i guess i would need to have a "server" process
> with pid XXXX that does an unshare(CLONE_NEWNS) and then listens for requests
> to fork client programs, and run-ns would need to send a request to that XXXX
> process to fork off <program> <args> and make sure that it can transfer all
> the pre-existing context of run-ns like pid/gid(s), cwd, environment, and i don't
> even know all the other context a linux process has these days. And then of course
> communicate exit status of <program> back from XXXX to run-ns.
>
> Meaning: it's great to have something like network name spaces, but without
> some setns(XXXX) system call, it's really difficult to use these network name
> spaces outside of a concept like LXC - which is a shame, because otherwise
> the nework name space woudl exactly be what i am looking for.

Definitely old docs.

ip netns add
ip netns delete
ip netns exec

And yes there is a setns system call.

If you don't have that you have old bits.  All of that should be merged
and documented.

Eric
