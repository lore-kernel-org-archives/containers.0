From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH] Introduce ActivePid: in /proc/self/status (v2, was
	Vpid:)
Date: Wed, 15 Jun 2011 21:03:02 +0200
Message-ID: <20110615190302.GA16440@redhat.com>
References: <20110615145527.4016.70157.stgit@bahia.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110615145527.4016.70157.stgit@bahia.local>
Sender: linux-kernel-owner@vger.kernel.org
To: Greg Kurz <gkurz@fr.ibm.com>
Cc: akpm@linux-foundation.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org, serge@hallyn.com, daniel.lezcano@free.fr, ebiederm@xmission.com, xemul@openvz.org
List-Id: containers.vger.kernel.org

Forgot to ask,

On 06/15, Greg Kurz wrote:
>
> The need arises in the LXC community when one wants to send a signal from
> the host (aka. init_pid_ns context) to a container process for which one
> only knows the pid inside the container.

I am just curious, why do you need this?

Oleg.
