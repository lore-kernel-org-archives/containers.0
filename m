From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PATCH 4/5] Add fair-user scheduler
Date: Mon, 24 Sep 2007 20:01:55 +0200
Message-ID: <20070924180155.GA551@elte.hu>
References: <20070924163326.GA10291@linux.vnet.ibm.com> <20070924164059.GE10291@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762592AbXIXSDL@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20070924164059.GE10291@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, dmitry.adamushko@gmail.com, linux-kernel@vger.kernel.org, dhaval@linux.vnet.ibm.com, containers@lists.osdl.org, kamezawa.hiroyu@jp.fujitsu.com, menage@google.com, efault@gmx.de
List-Id: containers.vger.kernel.org


* Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com> wrote:

> Enable user-id based fair group scheduling. This is usefull for anyone 
> who wants to test the group scheduler w/o having to enable 
> CONFIG_CGROUPS.

excellent! I'll make this default-enabled.

	Ingo
