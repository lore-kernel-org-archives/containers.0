From: "Paul Menage" <menage@google.com>
Subject: Re: [-mm PATCH] Memory controller improve user interface (v3)
Date: Sun, 2 Sep 2007 21:53:22 -0700
Message-ID: <6599ad830709022153g1720bcedsb61d7cf7a783bd3f@mail.gmail.com>
References: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753447AbXICEx4@vger.kernel.org>
In-Reply-To: <20070902105021.3737.31251.sendpatchset@balbir-laptop>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
To: Balbir Singh <balbir@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Linux MM Mailing List <linux-mm@kvack.org>, David Rientjes <rientjes@google.com>, Dave Hansen <haveblue@us.ibm.com>
List-Id: containers.vger.kernel.org

On 9/2/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
> -       s += sprintf(s, "%lu\n", *val);
> +       if (read_strategy)
> +               s += read_strategy(*val, s);
> +       else
> +               s += sprintf(s, "%lu\n", *val);

This would be better as %llu

> +               tmp = simple_strtoul(buf, &end, 10);

and this as simple_strtoull()

Paul
