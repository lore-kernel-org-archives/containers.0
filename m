From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH 01/10] Task Containers(V11): Basic task container framework
Date: Sun, 29 Jul 2007 10:03:49 -0700
Message-ID: <6599ad830707291003s38ccc07ds79b8d0e94469871d@mail.gmail.com>
References: <20070720191247.388947000@menage.corp.google.com>
	 <20070727053120.2EFAC1BF6B8@siro.lan>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932330AbXG2RE1@vger.kernel.org>
In-Reply-To: <20070727053120.2EFAC1BF6B8@siro.lan>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: YAMAMOTO Takashi <yamamoto@valinux.co.jp>
Cc: akpm@linux-foundation.org, dev@sw.ru, xemul@sw.ru, serue@us.ibm.com, vatsa@in.ibm.com, ebiederm@xmission.com, haveblue@us.ibm.com, svaidy@linux.vnet.ibm.com, balbir@in.ibm.com, pj@sgi.com, ckrm-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org, containers@lists.osdl.org, rohitseth@google.com
List-Id: containers.vger.kernel.org

On 7/26/07, YAMAMOTO Takashi <yamamoto@valinux.co.jp> wrote:
> > +Other fields in the container_subsys object include:
>
> > +- hierarchy: an index indicating which hierarchy, if any, this
> > +  subsystem is currently attached to. If this is -1, then the
> > +  subsystem is not attached to any hierarchy, and all tasks should be
> > +  considered to be members of the subsystem's top_container. It should
> > +  be initialized to -1.
>
> stale info?

Yes, I think so. I really need to do a proper pass over
Documentation/containers.txt one more time following a bunch of recent
changes.

>
> > +struct container {
>
> > +     struct containerfs_root *root;
> > +     struct container *top_container;
> > +};
>
> can cont->top_container be different from than &cont->root.top_container?

No, I guess it can't. And there are only a couple of places using
cont->top_container now, so I should probably remove it.

Thanks,

Paul
