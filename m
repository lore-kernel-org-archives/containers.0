From: "Serge E. Hallyn" <serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: Container for Amazon EC2?
Date: Wed, 17 Feb 2010 09:19:44 -0600
Message-ID: <20100217151943.GA9159@us.ibm.com>
References: <2c2629fa1002150243n4c91d93ctee4509912228f3ea@mail.gmail.com>
	<20100215143905.GD28038@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20100215143905.GD28038-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Jun OKAJIMA <okajima-og82NyAXoxRpnGNL948N7c8NsWr+9BEh@public.gmane.org>
Cc: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

So I tried running one of the public ubuntu karmic images in
ec2 (ami-bb709dd2).  I could sudo apt-get install lxc.  The
default kernel (aki-5f15f636) didn't support namespaces.  Now
you can specify kernels at boot, but I'm not sure if there is
an easy way to find kernels with specific CONFIG_ options.
I'll let you know if I find one with all namespaces and
veth+bridge+macvlan enabled, bc that would then give you
everything you'd need.

-serge

Quoting Serge E. Hallyn (serue-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org):
> It's been a little while (probably a year) since I played with
> EC2, but generally the problem is that you don't have much of
> a choice for underlying kernels.  So you can't pick vserver/openvz
> kernels, and the available kernels are too old to have containers
> features.  As kernels get updated, whether you can use lxc or not
> will only depend on whether CONFIG_{containers} features are compiled
> in.
> 
> It couldn't hurt to write the amazon folks and ask about it...
> 
> -serge
> 
> Quoting Jun OKAJIMA (okajima-og82NyAXoxRpnGNL948N7c8NsWr+9BEh@public.gmane.org):
> > Somebody know any Amazon EC2 Image which
> > supports any container technology?
> > Vserver/LXC/OpenVZ... Any technology is Okay,
> > I want to use pre-created image for EC2.
> > 
> > I found many images for Ubuntu 9.10,
> > but it lacks some support for LXC.
> > Fedora12 supports all functions of LXC,
> > but did not find any image.
> > 
> >       --- Okajima, Jun. Tokyo, Japan.
> > _______________________________________________
> > Containers mailing list
> > Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> > https://lists.linux-foundation.org/mailman/listinfo/containers
> _______________________________________________
> Containers mailing list
> Containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
> https://lists.linux-foundation.org/mailman/listinfo/containers
