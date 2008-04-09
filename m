From: "H. Peter Anvin" <hpa@zytor.com>
Subject: Re: [RFC][PATCH 0/7] Clone PTS namespace
Date: Wed, 09 Apr 2008 15:38:08 -0700
Message-ID: <47FD4550.1010700@zytor.com>
References: <20080408215333.GA8799@us.ibm.com> <47FC138B.4070408@zytor.com> <20080409162353.GA14044@us.ibm.com> <47FD046C.6070804@zytor.com> <20080409191634.GA25220@vino.hallyn.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1756705AbYDIWjj@vger.kernel.org>
In-Reply-To: <20080409191634.GA25220@vino.hallyn.com>
Sender: linux-kernel-owner@vger.kernel.org
To: serge@hallyn.com
Cc: sukadev@us.ibm.com, linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Pavel Emelyanov <xemul@openvz.org>, serue@us.ibm.com, clg@fr.ibm.com
List-Id: containers.vger.kernel.org

serge@hallyn.com wrote:
>> I'm just worried about the accumulation of what feels like ad hoc 
>> namespaces, causing a very large combination matrix, a lot of which don't 
>> make sense.
> 
> Hmm, if we were to just call this CLONE_NEWDEV, would that (a) make
> sense and (b) suitably address your (certainly valid) concern?
> 
> Basically for now CLONE_NEWDEV wouldn't yet be fully implemented, only
> unsharing unix98 ptys...

That would make sense to me.  Also see Eric's note about uevent, 
however; and there are probably other issues like it.

	-hpa
