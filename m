From: Dave Hansen <haveblue@us.ibm.com>
Subject: Re: [-mm PATCH]  Memory controller improve user interface
Date: Wed, 29 Aug 2007 11:45:48 -0700
Message-ID: <1188413148.28903.113.camel@localhost>
References: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757433AbXH2SqV@vger.kernel.org>
In-Reply-To: <20070829111030.9987.8104.sendpatchset@balbir-laptop>
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Linux Containers <containers@lists.osdl.org>, Paul Menage <menage@google.com>
List-Id: containers.vger.kernel.org

On Wed, 2007-08-29 at 16:40 +0530, Balbir Singh wrote:
> 
> 
> @@ -352,7 +353,7 @@ int mem_container_charge(struct page *pa
>                 kfree(pc);
>                 pc = race_pc;
>                 atomic_inc(&pc->ref_cnt);
> -               res_counter_uncharge(&mem->res, 1);
> +               res_counter_uncharge(&mem->res, MEM_CONTAINER_CHARGE_KB);
>                 css_put(&mem->css);
>                 goto done;
>         } 

Do these changes really need to happen anywhere besides the
user<->kernel boundary?  Why can't internal tracking be in pages?

-- Dave
