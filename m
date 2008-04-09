From: serge@hallyn.com
Subject: Re: [RFC][PATCH 0/7] Clone PTS namespace
Date: Wed, 9 Apr 2008 14:16:34 -0500
Message-ID: <20080409191634.GA25220@vino.hallyn.com>
References: <20080408215333.GA8799@us.ibm.com> <47FC138B.4070408@zytor.com> <20080409162353.GA14044@us.ibm.com> <47FD046C.6070804@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757309AbYDITUg@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <47FD046C.6070804@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: sukadev@us.ibm.com, linux-kernel@vger.kernel.org, Containers <containers@lists.osdl.org>, Pavel Emelyanov <xemul@openvz.org>, serue@us.ibm.com, clg@fr.ibm.com
List-Id: containers.vger.kernel.org

Quoting H. Peter Anvin (hpa@zytor.com):
> sukadev@us.ibm.com wrote:
>> We want to provide isolation between containers, meaning PTYs in container
>> C1 should not be accessible to processes in C2 (unless C2 is an ancestor).
>
> Yes, I certainly can understand the desire for isolation.  That wasn't what 
> my question was about.
>
>> The other reason for this in the longer term is for checkpoint/restart.
>> When restarting an application we want to make sure that the PTY indices
>> it was using is available and isolated.
>
> OK, this would be the motivation for index isolation.
>
>> A complete device-namespace could solve this, but IIUC, is being planned
>> in the longer term. We are hoping this would provide the isolation in the
>> near-term without being too intrusive or impeding the implementation of
>> the device namespace.
>
> I'm just worried about the accumulation of what feels like ad hoc 
> namespaces, causing a very large combination matrix, a lot of which don't 
> make sense.

Hmm, if we were to just call this CLONE_NEWDEV, would that (a) make
sense and (b) suitably address your (certainly valid) concern?

Basically for now CLONE_NEWDEV wouldn't yet be fully implemented, only
unsharing unix98 ptys...

-serge
