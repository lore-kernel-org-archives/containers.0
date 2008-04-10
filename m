From: Cedric Le Goater <clg@fr.ibm.com>
Subject: Re: [PATCH 1/3] change clone_flags type to u64
Date: Thu, 10 Apr 2008 15:23:00 +0200
Message-ID: <47FE14B4.4090705@fr.ibm.com>
References: <20080409222611.GA28087@us.ibm.com>	<20080409223231.GA28267@us.ibm.com>	<871w5enmk7.fsf@basil.nowhere.org> <47FE073B.3060007@fr.ibm.com> <20080410125205.GG10019@one.firstfloor.org> <47FE1219.5010405@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756966AbYDJNXU@vger.kernel.org>
In-Reply-To: <47FE1219.5010405@parallels.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Kirill Korotaev <dev@parallels.com>
Cc: Andi Kleen <andi@firstfloor.org>, "David C. Hansen" <haveblue@us.ibm.com>, linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Pavel Emelyanov <xemul@openvz.org>
List-Id: containers.vger.kernel.org

Kirill Korotaev wrote:
> The was no real rationale except for some people seeing "clone" functionality
> as the match and the fact that FS_NAMESCAPE was done so made them believe it 
> is a good way to go.
> And I warned about flags limitation at the beginning.

yes and now, we've hit the clone wall but that's a good thing.

> Both OpenVZ/vserver suggested to use a special syscall for handling this.

most projects do it that way.

> Maybe it is a good point to switch to it now finally and stop worring about all 
> this?

what would be the interface ? 

C. 

 
