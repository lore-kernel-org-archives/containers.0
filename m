From: serge@hallyn.com
Subject: Re: [RFC] Prefixing cgroup generic control filenames with "cgroup."
Date: Thu, 28 Feb 2008 15:33:19 -0600
Message-ID: <20080228213319.GC1232@vino.hallyn.com>
References: <6599ad830802281314s25c033d6tc021725ae28aef8d@mail.gmail.com> <20080228132142.4d4b1eef.akpm@linux-foundation.org> <6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932574AbYB1VgU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <6599ad830802281328q162d0585v3ac6b45a119a4a05@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Paul Menage <menage@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, containers@lists.osdl.org, linux-kernel@vger.kernel.org, balbir@linux.vnet.ibm.com, a.p.zijlstra@chello.nl, xemul@openvz.org, pj@sgi.com
List-Id: containers.vger.kernel.org

Quoting Paul Menage (menage@google.com):
> On Thu, Feb 28, 2008 at 1:21 PM, Andrew Morton
> <akpm@linux-foundation.org> wrote:
> 
> >
> >  Because if something is in /foo/bar/cgroup/notify_on_release then
> >  prefixing the filename with "cgroup_" seems pretty pointless.
> >
> 
> The point would be to avoid situations where a user has code that
> creates a group directory called "foo", and then in a future kernel
> release cgroups introduces a control file called "foo". If it's
> prefixed, then the user just has to avoid creating groups prefixed by
> "cgroup." or any subsystem name, so collisions will be less likely.

Have you already run into that case?

You said the set of files belong to cgroup itself is likely to increase
- do you have some candidates in mind?  Perhaps ones which are likely
to conflict with choice taskgroup names?

If anything I'd say add a 'prefix_cgroup' mount option and use it to
decide whether to prefix or not (rather than use the noprefix option).

-serge
