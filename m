From: Pierre Peiffer <pierre.peiffer@bull.net>
Subject: Re: [PATCH 2.6.24-rc3-mm1] IPC: make struct ipc_ids static in ipc_namespace
Date: Fri, 23 Nov 2007 12:40:27 +0100
Message-ID: <4746BC2B.6060002@bull.net>
References: <20071122155448.3193c856.pierre.peiffer@bull.net> <474680B5.7020104@fr.ibm.com> <47468347.5090303@openvz.org> <47468927.3040304@openvz.org> <47469630.3060807@bull.net> <47469CF3.1030200@openvz.org> <4746B027.4020506@bull.net> <4746B449.5010204@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756770AbXKWLk4@vger.kernel.org>
In-Reply-To: <4746B449.5010204@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Cedric Le Goater <clg@fr.ibm.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, containers@lists.osdl.org
List-Id: containers.vger.kernel.org

Pavel Emelyanov wrote:
> Well I think you're right. The structure gains 50% in size... Really too
> much to fight for performance in IPC :)
> 
> Thanks for checking this thing.
> 
> You may put my Acked-by in the original patch.
> 

Cool. Thanks !

P.

> Thanks,
> Pavel
> 

-- 
Pierre Peiffer
