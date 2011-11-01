From: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Tue, 01 Nov 2011 16:55:04 +0100
Message-ID: <4EB01658.6060702@free.fr>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
	<m1r51swmun.fsf@fess.ebiederm.org>
	<20111101043201.GA14734@faui40p.informatik.uni-erlangen.de>
	<m1lis0vxu6.fsf@fess.ebiederm.org>
	<20111101152624.GB14734@faui40p.informatik.uni-erlangen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20111101152624.GB14734-+4JsuViRYHWM0MU9lROt9PpTrGXM5HoexJJUWDj/nkeELgA04lAiVw@public.gmane.org>
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
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
List-Id: containers.vger.kernel.org

On 11/01/2011 04:26 PM, Toerless Eckert wrote:
> THanks for replying,
>
> Sorry for asking what probably are a lot of naive questions, my excuse is
> that the documentation is somewhat scattered/incomplete ? ;-))
>
> I am trying to figure out how to minimize the virtualization to just the network
> name space and instantiate it in a lightweight fashion that can easily
> be counterfitted into some existing system.
>
> What i would like to have is some simple program like "run-ns XXXX<program>  <args>"
> that would run program<args>  within namespace XXXX.

Did you look at the lxc-execute command ?

http://lxc.sourceforge.net/man/lxc.html

the "Quick Start" section, third line.

   -- Daniel
