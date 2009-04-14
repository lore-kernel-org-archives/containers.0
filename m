From: Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 10/30] cr: core stuff
Date: Tue, 14 Apr 2009 21:28:33 +0400
Message-ID: <20090414172833.GA27985__11544.0391622998$1239730465$gmane$org@x200.localdomain>
References: <20090410023539.GK27788@x200.localdomain>
	<49E41D7B.8030003@cs.columbia.edu>
	<20090414160003.GD27461@x200.localdomain>
	<1239727190.32604.72.camel@nimitz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1239727190.32604.72.camel@nimitz>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Dave Hansen <dave-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Cc: xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org, containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, hch-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org, akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org, mingo-X9Un+BFzKDI@public.gmane.org
List-Id: containers.vger.kernel.org

On Tue, Apr 14, 2009 at 09:39:50AM -0700, Dave Hansen wrote:
> On Tue, 2009-04-14 at 20:00 +0400, Alexey Dobriyan wrote:
> > > Are you suggesting that conversion of a checkpoint image from an older
> > > version to a newer version be done in the kernel ?
> > 
> > For mainline kernel it's completely unrealistic to support all backwards
> > compatibility code for previous versions. Some mythical userspace
> > program will convert images.
> > 
> > But it's completely realistic and much easier for distro kernel because
> > distro kernel doesn't generally include patches with significant in-kernel
> > internals changes, so they simply can support
> > '2.6.26-1-amd64' => '2.6.26-2-amd64' situation.
> > 
> > Distros can write conversion program too, but I don't expect they will.
> 
> Yeah, I'm with you on this.  If distros ever start to care about c/r
> *that* much, they'll start making this part of their testing process.
> Personally, I think just giving a kernel version is pretty worthless
> these days.  People do tons of stuff to the kernel without bumping it at
> all. 

Well, to some extent this is cop-out.

It allows to easily see (hexdump(1) :-) what kernel dumped image.
And it allows for distro to easily check if it's restart on same version
or from previous version with high degree of confidentness.

Distro kernels have very specific unames if looking for kernels and
kernel updates they officially ship, but yes, this is not 100% reliable.
