Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 8360B70
	for <containers@lists.linux.dev>; Wed,  9 Jun 2021 08:09:23 +0000 (UTC)
Received: by mail.kernel.org (Postfix) with ESMTPSA id 257BE61361;
	Wed,  9 Jun 2021 08:09:20 +0000 (UTC)
Date: Wed, 9 Jun 2021 10:09:18 +0200
From: Christian Brauner <christian.brauner@ubuntu.com>
To: Hannes Reinecke <hare@suse.de>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>, gregkh@linuxfoundation.org,
	containers@lists.linux.dev, linux-kernel@vger.kernel.org,
	lkml@metux.net
Subject: Re: device namespaces
Message-ID: <20210609080918.ma2klvxkjad4pjrn@wittgenstein>
References: <YL9liW99Ytf6uBlu@kroah.com>
 <9157affa-b27a-c0f4-f6ee-def4a991fd4e@suse.de>
 <20210608142911.ievp2rpuquxjuyus@wittgenstein>
 <d956398e-7ee6-ba36-43cc-4cdcea34b5b9@suse.de>
 <877dj4ff9g.fsf@disp2133>
 <20210609063818.xnod4rzvti3ujkvn@wittgenstein>
 <b9ea9116-7120-b0a7-b739-dd8513e12c5e@suse.de>
 <20210609072108.ldhsxfnfql4pacqx@wittgenstein>
 <85a0d777-dea6-9574-8946-9fc8f912c1af@suse.de>
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
In-Reply-To: <85a0d777-dea6-9574-8946-9fc8f912c1af@suse.de>

On Wed, Jun 09, 2021 at 09:54:05AM +0200, Hannes Reinecke wrote:
> On 6/9/21 9:21 AM, Christian Brauner wrote:
> > On Wed, Jun 09, 2021 at 09:02:36AM +0200, Hannes Reinecke wrote:
> >> On 6/9/21 8:38 AM, Christian Brauner wrote:
> >>> On Tue, Jun 08, 2021 at 12:16:43PM -0500, Eric W. Biederman wrote:
> >>>> Hannes Reinecke <hare@suse.de> writes:
> >>>>
> >>>>> On 6/8/21 4:29 PM, Christian Brauner wrote:
> >>>>>> On Tue, Jun 08, 2021 at 04:10:08PM +0200, Hannes Reinecke wrote:
> >> [ .. ]
> >>>>> Granted, modifying sysfs layout is not something for the faint-hearted,
> >>>>> and one really has to look closely to ensure you end up with a
> >>>>> consistent layout afterwards.
> >>>>>
> >>>>> But let's see how things go; might well be that it turns out to be too
> >>>>> complex to consider. Can't tell yet.
> >>>>
> >>>> I would suggest aiming for something like devptsfs without the
> >>>> complication of /dev/ptmx.
> >>>>
> >>>> That is a pseudo filesystem that has a control node and virtual block
> >>>> devices that were created using that control node.
> >>>
> >>> Also see android/binder/binderfs.c
> >>>
> >> Ah. Will have a look.
> > 
> > I implemented this a few years back and I think it should've made it
> > onto Android by default now. So that approach does indeed work well, it
> > seems:
> > https://chromium.googlesource.com/aosp/platform/system/core/+/master/rootdir/init.rc#257
> > 
> > This should be easier to follow than the devpts case because you don't
> > need to wade through the {t,p}ty layer.
> > 
> >>
> >>>>
> >>>> That is the cleanest solution I know and is not strictly limited to use
> >>>> with containers so it can also gain greater traction.  The interaction
> >>>> with devtmpfs should be simply having devtmpfs create a mount point for
> >>>> that filesystem.
> >>>>
> >>>> This could be a new cleaner api for things like loopback devices.
> >>>
> >>> I sent a patchset that implemented this last year.
> >>>
> >> Do you have a pointer/commit hash for this?
> > 
> > Yes, sure:
> > https://lore.kernel.org/linux-block/20200424162052.441452-1-christian.brauner@ubuntu.com/
> > 
> > You can also just pull my branch. I think it's still based on v5.7 or sm:
> > https://git.kernel.org/pub/scm/linux/kernel/git/brauner/linux.git/log/?h=loopfs
> > 
> > I'm happy to collaborate on this too.
> >
> How _very_ curious. 'kernfs: handle multiple namespace tags' and 'loop:
> preserve sysfs backwards compability' are essentially the same patches I
> did for my block namespaces prototyp; I named it 'KOBJ_NS_TYPE_BLK', not
> 'KOBJ_NS_TYPE_USER', though :-)
> 
> Guess we really should cooperate.
> 
> Speaking of which: why did you name it 'user' namespace?
> There already is a generic 'user_namespace' in
> include/linux/user_namespace.h, serving as a container for all
> namespaces; as such it probably should include this 'user' namespace,
> leading to quite some confusion.
> 
> Or did I misunderstood something here?

Ah yes, you misunderstand. The KOBJ_NS_TYPE_* tags are namespace tags.
So KOBJ_NS_TYPE_NET is a network namespace tag. So KOBJ_NS_TYPE_USER is
a user namespace tag not a completely new namespace. The idea very
roughly being that devices such as loop devices are ultimately filtered
by user namespace which is taken from the s_user_ns the loopfs instance
is mounted in. We should compare notes.

Christian
