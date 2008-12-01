From: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Subject: Re: [RFC][PATCH 4/5] Protect cinit from fatal signals
Date: Mon, 1 Dec 2008 12:21:12 -0800
Message-ID: <20081201202112.GC12493@us.ibm.com>
References: <20081126034242.GA23120@us.ibm.com> <20081126034634.GD23238@us.ibm.com> <20081127010753.GB13545@wavehammer.waldi.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753789AbYLAUVw@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081127010753.GB13545@wavehammer.waldi.eu.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Bastian Blank <bastian@waldi.eu.org>, oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

Bastian Blank [bastian@waldi.eu.org] wrote:
| On Tue, Nov 25, 2008 at 07:46:34PM -0800, Sukadev Bhattiprolu wrote:
| > To protect container-init from fatal signals, set SIGNAL_UNKILLABLE but
| > clear it if it receives SIGKILL from parent namespace - so it is still
| > killable from ancestor namespace.
| 
| This sounds like a workaround.

yes...
| 
| > Note that container-init is still somewhat special compared to 'normal
| > processes' - unhandled fatal signals like SIGUSR1 to a container-init
| > are dropped even if they are from ancestor namespace. SIGKILL from an
| > ancestor namespace is the only reliable way to kill a container-init.
| 
| It sounds not right to make this special case for a "normal" process.
| 
| However, no idea how to do this better.

... like I mentioned in the other message, we have tried different
approaches and they were either intrusive or required more drastic
changes in semantics.

Container-inits are special in some ways and this change requires SIGKILL
to terminate them.
