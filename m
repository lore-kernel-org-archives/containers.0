From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] extend clone_flags using parent_tidptr argument
Date: Mon, 4 Feb 2008 13:38:10 -0800
Message-ID: <20080204133810.0077ec0d.akpm@linux-foundation.org>
References: <47A74AED.1080806@free.fr>
	<20080204202416.GA26422@sergelap.austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757524AbYBDVij@vger.kernel.org>
In-Reply-To: <20080204202416.GA26422@sergelap.austin.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "Serge E. Hallyn" <serue@us.ibm.com>
Cc: legoater@free.fr, linux-kernel@vger.kernel.org, containers@lists.osdl.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Mon, 4 Feb 2008 14:24:16 -0600
"Serge E. Hallyn" <serue@us.ibm.com> wrote:

> Quoting Cedric Le Goater (legoater@free.fr):
> > From: Cedric Le Goater <clg@fr.ibm.com>
> >
> > We have at least 2 patchsets requiring each a new clone flag and there it 
> > is, we've reached the limit, none are left.  
> > This patch uses the CLONE_DETACHED flag (unused) as a marker to extend the 
> 
> Are we pretty sure that there is no legacy software out there which has
> continued to specify CLONE_DETACHED since the kernel ignores it?

Please see -mm's
clone-prepare-to-recycle-clone_detached-and-clone_stopped.patch

That patch has been cut back to only recycle CLONE_STOPPED because there
indeed was software out there which is setting CLONE_DETACHED.

See http://linux.derkeiler.com/Mailing-Lists/Kernel/2007-11/msg04293.html
