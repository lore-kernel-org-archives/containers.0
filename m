From: Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
Subject: Re: LXC L3 network isolation, yes/no ?, how ?
Date: Wed, 2 Nov 2011 20:51:42 +0100
Message-ID: <20111102195142.GC14734@faui40p.informatik.uni-erlangen.de>
References: <20111101021230.GE15906@faui40p.informatik.uni-erlangen.de>
	<m1r51swmun.fsf@fess.ebiederm.org>
	<20111101043201.GA14734@faui40p.informatik.uni-erlangen.de>
	<m1lis0vxu6.fsf@fess.ebiederm.org>
	<20111101152624.GB14734@faui40p.informatik.uni-erlangen.de>
	<m1hb2nsqy6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <m1hb2nsqy6.fsf-+imSwln9KH6u2/kzUuoCbdi2O/JbrIOy@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: "Eric W. Biederman" <ebiederm-aS9lmoZGLiVWk0Htik3J/w@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, Toerless Eckert <Toerless.Eckert-vrlraubKdiR4tiELkoLHDcSSVFg4/55HhC4ANOJQIlc@public.gmane.org>
List-Id: containers.vger.kernel.org

Cool. Although i would claim my bits are "current", and your bits
are "bleeding edge". Just found the iproute2 package that supports this
on my gentoo by getting the latest cvs version only... ;-)

The biggest issue seems to be that setns() is only in 3.0 linux kernels
as far as i can see. Have to check whether that's a possible version on the
systems where i need it.

But at least this is technically cool and makes these network name spaces
much more flexible useable (eg: inside and outside of LXC).

Cheers
    Toerless

On Tue, Nov 01, 2011 at 10:17:05AM -0700, Eric W. Biederman wrote:
> > some setns(XXXX) system call, it's really difficult to use these network name
> > spaces outside of a concept like LXC - which is a shame, because otherwise
> > the nework name space woudl exactly be what i am looking for.
> 
> Definitely old docs.
> 
> ip netns add
> ip netns delete
> ip netns exec
> 
> And yes there is a setns system call.
> 
> If you don't have that you have old bits.  All of that should be merged
> and documented.
> 
> Eric
