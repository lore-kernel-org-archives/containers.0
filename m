From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 5/8] af_netlink: Add needed scm_destroy after scm_send.
Date: Mon, 14 Jun 2010 15:37:43 +0200
Message-ID: <4C1630A7.8000505@free.fr>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1ljajgiud.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1ljajgiud.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, Serge Hallyn <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On 06/13/2010 03:31 PM, Eric W. Biederman wrote:
> scm_send occasionally allocates state in the scm_cookie, so I have
> modified netlink_sendmsg to guarantee that when scm_send succeeds
> scm_destory will be called to free that state.
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
> ---
>    

Reviewed-by: Daniel Lezcano <daniel.lezcano@free.fr>
