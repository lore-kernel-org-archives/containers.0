From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [-mm PATCH]  Memory controller improve user interface (v3)
Date: Tue, 04 Sep 2007 12:03:13 -0700
Message-ID: <1188932593.28903.357.camel@localhost>
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754719AbXIDTD3@vger.kernel.org>
In-Reply-To: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>
List-Id: containers.vger.kernel.org

On Sun, 2007-09-02 at 16:20 +0530, Balbir Singh wrote:
> 
> +Setting a limit to a number that is not a multiple of page size causes
> +rounding up of the value. The user must check back to see (by reading
> +memory.limit_in_bytes), to check for differences between desired values and
> +committed values. Currently, all accounting is done in multiples of PAGE_SIZE 

I wonder if we can say this in a bit more generic fashion.

        A successful write to this file does not guarantee a successful
        set of this limit to the value written into the file.  This can
        be due to a number of factors, such as rounding up to page
        boundaries or the total availability of memory on the system.
        The user is required to re-read this file after a write to
        guarantee the value committed by the kernel.

This keeps a user from saying "I page aligned the value I stuck in
there, no I don't have to check it."

-- Dave
