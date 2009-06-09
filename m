From: Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
Subject: Re: [BUG] net_cls: Panic occured when net_cls subsystem use
Date: Tue, 9 Jun 2009 09:02:19 +0900
Message-ID: <20090609090219.018dda69.usui__4719.70434668965$1244506100$gmane$org@mxm.nes.nec.co.jp>
References: <20090521092256.d33717b9.usui@mxm.nes.nec.co.jp>
	<20090601181201.ca1c2832.usui@mxm.nes.nec.co.jp>
	<20090608153951.dfa4b162.usui@mxm.nes.nec.co.jp>
	<20090608074814.GA4972@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <20090608074814.GA4972-8HppEYmqbBCE+EvaaNYduQ@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Cc: tgraf-G/eBtMaohhA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, hadi-fAAogVwAN2Kw5LPnMra/2Q@public.gmane.org
List-Id: containers.vger.kernel.org

Hi, Jarek

On Mon, 8 Jun 2009 07:48:14 +0000
Jarek Poplawski <jarkao2-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:

> On Mon, Jun 08, 2009 at 03:39:51PM +0900, Minoru Usui wrote:
> > Hi Thomas
> > 
> > On Mon, 1 Jun 2009 18:12:01 +0900
> > Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > 
> > > Hi Thomas
> > > 
> > > Original mail sent to netdev and containers before.
> > > (http://www.spinics.net/lists/netdev/msg97745.html)
> > > 
> > > I have a question about how to use cls_cgroup.
> > > 
> > > On Thu, 21 May 2009 09:22:56 +0900
> > > Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org> wrote:
> > > 
> > > > Hi
> > > > 
> > > > Unfortunately this is only panic report.
> > > > 
> > > > I used cgroup net_cls subsystem, then kernel panic occured.
> > > > I attach panic message and kernel config in this mail's last paragraph.
> > > > If my operation is wrong, could you tell me how to use net_cls and
> > > > where the documentation is. 
> > > > 
> > > > # But I think panic is very bad even if my operation is wrong.
> > > 
> > > The cause of panic will fix soon. (Now I'll make a patch and will test it.)
> > > 
> > > I want to know how to use cls_cgroup correctly, so could you tell me how to use it if my operation is wrong. 
> > > Now, I think I might have to specify 'handle' with tc command line, is this true?
> > > But when I specified 'handle', I faced oops. X-P
> > 
> > I investigated this problem, and I found a bug in cls_cgroup_change() in cls_cgroup.c.
> > cls_cgroup_change() expected tca[TCA_OPTIONS] was set from user space properly,
> > but tc in iproute2-2.6.29-1 (which I used) didn't set it.
> > 
> > I saw the current source code of tc in git, I found the code for cls_cgroup in iproute2/tc/f_cgroup.c.
> > It set tca[TCA_OPTIONS].
> > 
> >   git://git.kernel.org/pub/scm/linux/kernel/git/shemminger/iproute2.git
> > 
> > # Unfortunately, current source coude of iproute2 couldn't compile, because it occured compile error. X-P
> > # But this is another issue.
> > 
> > If we always use a newest iproute2 in git when we use cls_cgroup, we don't face this oops probably.
> > But I think, kernel shouldn't panic regardless of use program's behaviour. 
> > 
> 
> This patch looks OK to me, but I guess you should add some title (plus
> "[PATCH]" in the subject), and a changelog (with lines width <= 80).

Thank you for your comments.
I'll resend my patch as a start of a new thread.

-- 
Minoru Usui <usui-vEbCzmPPqHe45+QrQBaojngSJqDPrsil@public.gmane.org>
