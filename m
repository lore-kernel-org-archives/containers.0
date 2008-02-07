From: "Paul Menage" <menage@google.com>
Subject: Re: [PATCH][DOCUMENTATION] Minimal controller code for a quick start
Date: Thu, 7 Feb 2008 12:49:25 -0800
Message-ID: <6599ad830802071249g45cb2d6eybd00c1bef07cf5aa@mail.gmail.com>
References: <47AB25AD.30400@openvz.org> <1202416137.6274.42.camel@lappy>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762541AbYBGUtn@vger.kernel.org>
In-Reply-To: <1202416137.6274.42.camel@lappy>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Linux Containers <containers@lists.osdl.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
List-Id: containers.vger.kernel.org

On Feb 7, 2008 12:28 PM, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
>
> While on the subject, could someone document struct cgroup_subsys.

There's documentation for all the methods in Documentation/cgroup.txt

> particular, I've wondered why we have: cgroup_subsys::can_attach() and
> not use a return value in cgroup_subsys::attach()?

We could do in theory do that, but it would make the recovery logic in
cgroup.c:attach_task() more complex - it would have to be able to deal
with undoing a partial attach. It seems simpler to just split it into
two phases, given that most cgroups don't appear to have attachment
conditions anyway.

Paul
