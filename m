From: chris-SqNQQPNds68nxqbYAscKCQ@public.gmane.org
Subject: Re: Net containers config and usage
Date: Wed, 14 Jan 2009 09:27:39 -0800
Message-ID: <20090114172739.GA13581@versecorp.net>
References: <20090112223545.GA15781@versecorp.net>
	<20090112225140.GA29834@us.ibm.com>
	<20090113005436.GA26167@versecorp.net> <496C4EB0.30203@free.fr>
	<20090113142925.GA11767@us.ibm.com>
	<20090113191837.GA29900@versecorp.net> <496CF11A.7090908@free.fr>
	<20090113214747.GA23742@versecorp.net>
	<1231887220.6398.73.camel@groeck-laptop> <496DA755.1040001@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <496DA755.1040001-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: "containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org" <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>
List-Id: containers.vger.kernel.org

On Wed, Jan 14, 2009 at 09:50:29AM +0100, Daniel Lezcano wrote:
> Guenter Roeck wrote:
> >As far as I recall, if you have sysfs active and use the sysfs patch to
> >let you configure both sysfs and network namespaces, you can only move
> >virtual interfaces into a network namespace.
> >
> >Guenter
> >  
> Ah ! yes, you are right :)
> 
> The current upstream implementation allowing sysfs and netns to coexist 
> together has one restriction, the physical network devices can not be 
> moved if sysfs is enabled in the kernel. This is why Chris can not move 
> the physical network device with this version of the kernel.
> This restriction will be set until the sysfs per namespace is fully 
> supported.
> 
> This restriction does not exist with with the previous kernel version 
> with the sysfs per namespace patchset.
> 
> -- Daniel
> 

Ah, great, thanks to all for your help on this.
Do you have any rough estimate when the support for sysfs per namespace will
be added in the upstream?

Thanks again,
Chris
