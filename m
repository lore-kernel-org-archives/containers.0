From: "Michael Kerrisk" <mtk.linux.lists@gmail.com>
Subject: Re: [RFC][PATCH 0/2] New API to change the IDs of an existing IPC
Date: Sun, 30 Sep 2007 08:30:55 +0200
Message-ID: <517f3f820709292330i56caf106yfa18778d741f8e1a@mail.gmail.com>
References: <20070928165829.5da76796.Pierre.Peiffer@bull.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755037AbXI3GbM@vger.kernel.org>
In-Reply-To: <20070928165829.5da76796.Pierre.Peiffer@bull.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Pierre Peiffer <Pierre.Peiffer@bull.net>
Cc: linux-kernel@vger.kernel.org, containers@lists.osdl.org, mtk-manpages@gmx.net
List-Id: containers.vger.kernel.org

Hi Pierre,

>         As I'm seeing some discussion/interest about IPC, I would like to propose
>  these patches, which provide an easy way to change the ID of an exiting IPC.
> This work is done around the checkpoint/restart of applications. In the case of
> the IPCs, we need (among others) this functionality.

Can you give some more detailed explanation of why this
functionaility is needed.  (Maybe this was explained in other threads,
but if so I've missed it.)

Cheers,

Michael
