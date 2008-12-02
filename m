From: Bastian Blank <bastian@waldi.eu.org>
Subject: Re: [RFC][PATCH 4/5] Protect cinit from fatal signals
Date: Tue, 2 Dec 2008 13:06:06 +0100
Message-ID: <20081202120606.GD1132@wavehammer.waldi.eu.org>
References: <20081126034242.GA23120@us.ibm.com> <20081126034634.GD23238@us.ibm.com> <20081127010753.GB13545@wavehammer.waldi.eu.org> <20081201202112.GC12493@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754710AbYLBMGU@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081201202112.GC12493@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: oleg@redhat.com, ebiederm@xmission.com, roland@redhat.com, containers@lists.osdl.org, linux-kernel@vger.kernel.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

On Mon, Dec 01, 2008 at 12:21:12PM -0800, Sukadev Bhattiprolu wrote:
> Container-inits are special in some ways and this change requires SIGKILL
> to terminate them.

No. They have are not special from the outside namespace.

Also it was discussed to use pid namespaces to preserve the local pid of
a process during snapshot/restore. This means that every process may get
the state of a container-init. And then it is not longer a wise idea to
make them behave different from the outside.

Bastian

-- 
I'm a soldier, not a diplomat.  I can only tell the truth.
		-- Kirk, "Errand of Mercy", stardate 3198.9
