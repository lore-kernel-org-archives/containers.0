From: Cedric Le Goater <legoater@free.fr>
Subject: Re: [PATCH 2/2] extend clone_flags using parent_tidptr argument
Date: Tue, 05 Feb 2008 09:20:43 +0100
Message-ID: <47A81C5B.9080000@free.fr>
References: <47A74AED.1080806@free.fr>	<20080204202416.GA26422@sergelap.austin.ibm.com> <20080204133810.0077ec0d.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757707AbYBEIU6@vger.kernel.org>
In-Reply-To: <20080204133810.0077ec0d.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Serge E. Hallyn" <serue@us.ibm.com>, linux-kernel@vger.kernel.org, containers@lists.osdl.org, xemul@openvz.org
List-Id: containers.vger.kernel.org

Andrew Morton wrote:
> On Mon, 4 Feb 2008 14:24:16 -0600
> "Serge E. Hallyn" <serue@us.ibm.com> wrote:
> 
>> Quoting Cedric Le Goater (legoater@free.fr):
>>> From: Cedric Le Goater <clg@fr.ibm.com>
>>>
>>> We have at least 2 patchsets requiring each a new clone flag and there it 
>>> is, we've reached the limit, none are left.  
>>> This patch uses the CLONE_DETACHED flag (unused) as a marker to extend the 
>> Are we pretty sure that there is no legacy software out there which has
>> continued to specify CLONE_DETACHED since the kernel ignores it?
> 
> Please see -mm's
> clone-prepare-to-recycle-clone_detached-and-clone_stopped.patch
> 
> That patch has been cut back to only recycle CLONE_STOPPED because there
> indeed was software out there which is setting CLONE_DETACHED.
> 
> See http://linux.derkeiler.com/Mailing-Lists/Kernel/2007-11/msg04293.html

bummer, I used the wrong one :/
 
Thanks,

C.
