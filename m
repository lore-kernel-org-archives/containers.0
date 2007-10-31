From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/5] The config option itself
Date: Wed, 31 Oct 2007 15:29:15 -0700
Message-ID: <20071031152915.c0b57c73.akpm@linux-foundation.org>
References: <47285FEE.9030001@openvz.org>
	<4728615D.5070700@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757397AbXJaW3g@vger.kernel.org>
In-Reply-To: <4728615D.5070700@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: ebiederm@xmission.com, clg@fr.ibm.com, serue@us.ibm.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, 31 Oct 2007 14:05:01 +0300
Pavel Emelyanov <xemul@openvz.org> wrote:

> The option is called NAMESPACES. It can be selectable only
> if EMBEDDED is chosen (this was Eric's requisition). When
> the EMBEDDED is off namespaces will be on automatically.

I'm thinking that Eric's pidns-place-under-config_experimental.patch is for
2.6.24, so I attempted to rework your patches atop that but gave up on the
last one.

So if we're agreeeable, can you please redo these against next -mm, thanks.

Also, please do put a little thought into the choice of patch subjects. 
"the config option itself" will look rather dopey if it goes into the
permanent kernel record under that name.

Probably putting "CONFIG_NAMESPACES: " in front of each of these would
suit.
