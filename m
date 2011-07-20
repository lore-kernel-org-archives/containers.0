From: Tejun Heo <tj@kernel.org>
Subject: Re: [EXAMPLE CODE] Parasite thread injection using PTRACE_SEIZE and
 friends
Date: Wed, 20 Jul 2011 16:03:35 +0200
Message-ID: <20110720140335.GN3455@htj.dyndns.org>
References: <20110720140037.GM3455@htj.dyndns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20110720140037.GM3455@htj.dyndns.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@parallels.com>, Nathan Lynch <ntl@pobox.com>, Oren Laadan <orenl@cs.columbia.edu>, Daniel Lezcano <dlezcano@fr.ibm.com>, Serge Hallyn <serue@us.ibm.com>, Cyri
Cc: Linux Containers <containers@lists.osdl.org>, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On Wed, Jul 20, 2011 at 04:00:37PM +0200, Tejun Heo wrote:
> With new ptrace requests, a process can be captured and manipulated
> practically transparently.  Other than syscall retry or -EINTR failure
> in special cases and timing difference, everything including job
> control stop state stays transparent across ptrace operations.

Ooh, forgot to mention something.  The ptracer can also reliably
determine whether job control stop is in effect or not, so the whole
job control state can be captured.

Thanks.

-- 
tejun
