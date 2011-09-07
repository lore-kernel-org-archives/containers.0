From: Vasiliy Kulikov <segoon-cxoSlKxDwOJWk0Htik3J/w@public.gmane.org>
Subject: Re: [patch 2/2] fs, proc: Introduce the /proc/<pid>/map_files/
	directory v6
Date: Wed, 7 Sep 2011 15:23:01 +0400
Message-ID: <20110907112301.GA12157@albatros>
References: <20110901080508.GF30615@sun> <20110902163711.GA3124@albatros>
	<20110905185358.GA2103@albatros> <20110905192009.GJ761@sun>
	<20110905194908.GA2690@albatros> <20110905203627.GL761@sun>
	<20110906101518.GA4799@albatros>
	<20110906165144.GJ18425@mtj.dyndns.org>
	<20110906172952.GA28055@albatros>
	<20110906173341.GM18425@mtj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20110906173341.GM18425-9pTldWuhBndy/B6EtB590w@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Tejun Heo <tj-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Cc: kernel-hardening-ZwoEplunGu1jrUoiu81ncdBPR1lH4CV8@public.gmane.org, Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, James Bottomley <jbottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>, Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Nathan Lynch <ntl-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org>, Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org, Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>, Daniel Lezcano <dlezcano-NmTC/0ZBporQT0dZR+AlfA@public.gmane.org>, Al Viro <viro-3bDd1+5oDREiFSDQTTA3OLVCufUGDwFn@public.gmane.org>
List-Id: containers.vger.kernel.org

Hi,

On Wed, Sep 07, 2011 at 02:33 +0900, Tejun Heo wrote:
> On Tue, Sep 06, 2011 at 09:29:52PM +0400, Vasiliy Kulikov wrote:
> > I agree with you.  I don't think that showing system-global debug
> > information to all users by default is the right thing.  But some people
> > doesn't agree with this point of view:
> > 
> > http://thread.gmane.org/gmane.linux.kernel/1108378
> 
> Yeap, I know there are two sides of the discussion but if one takes
> the position that hiding such global debug info is more harmful, it's
> only crazier to hide such information from each individual users of
> the said global facility.  So, let's just forget about information
> leak via freeing or not freeing here.  It's the wrong battle field.

Andrew, are you OK with closing the hole with pid_no_revalidate()
and 0600 /proc/slabinfo?  If so, I feel I have to start this discussion
with people participating in the discussion above: Theodore, Dan, Linus, etc.

Thanks,

-- 
Vasiliy Kulikov
http://www.openwall.com - bringing security into open computing environments
