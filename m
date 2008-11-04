From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/7] netns ebtables: part 2
Date: Tue, 04 Nov 2008 14:27:50 +0100
Message-ID: <49104DD6.6050604@trash.net>
References: <20081029134611.GB8396@x200.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081029134611.GB8396@x200.localdomain>
Sender: netfilter-devel-owner@vger.kernel.org
To: Alexey Dobriyan <adobriyan@gmail.com>
Cc: netfilter-devel@vger.kernel.org, containers@osdl.org
List-Id: containers.vger.kernel.org

Alexey Dobriyan wrote:
> * return ebt_table from ebt_register_table(), module code will save it into
>   per-netns data for unregistration
> * duplicate ebt_table at the very beginning of registration -- it's added into
>   list, so one ebt_table wouldn't end up in many lists (and each netns has
>   different one)
> * introduce underscored tables in individial modules, this is temporary to not
>   break bisection.

Applied, thanks.
