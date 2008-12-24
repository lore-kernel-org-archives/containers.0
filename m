From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC][PATCH 6/7][v4] SI_USER: Masquerade si_pid when crossing
	pid ns boundary
Date: Wed, 24 Dec 2008 17:18:51 +0100
Message-ID: <20081224161851.GD11593@redhat.com>
References: <20081224114414.GA7879@us.ibm.com> <20081224115301.GF8020@us.ibm.com> <20081224154310.GA11593@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752189AbYLXQUt@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081224154310.GA11593@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
To: Sukadev Bhattiprolu <sukadev@linux.vnet.ibm.com>
Cc: ebiederm@xmission.com, roland@redhat.com, bastian@waldi.eu.org, daniel@hozac.com, xemul@openvz.org, containers@lists.osdl.org, linux-kernel@vger.kernel.org
List-Id: containers.vger.kernel.org

On 12/24, Oleg Nesterov wrote:
>
> ? Why should we check SI_USER and change sys_kill() ?
                                ^^^^^^^^^^^^^^^^^^^
I'm afraid I wasn't clear...

> see also the comment for the next 7/7 patch.

yes, please see the next comment.

Oleg.
