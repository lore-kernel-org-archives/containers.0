From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: [PATCH 4/8] af_unix: Allow SO_PEERCRED to work across namespaces.
Date: Mon, 14 Jun 2010 15:37:57 +0200
Message-ID: <4C1630B5.4000301@free.fr>
References: <m1hbl7hxo3.fsf@fess.ebiederm.org> <m1r5kbgivt.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <m1r5kbgivt.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Cc: David Miller <davem@davemloft.net>, Serge Hallyn <serue@us.ibm.com>, Linux Containers <containers@lists.osdl.org>, netdev@vger.kernel.org, Pavel Emelyanov <xemul@parallels.com>
List-Id: containers.vger.kernel.org

On 06/13/2010 03:30 PM, Eric W. Biederman wrote:
> Use struct pid and struct cred to store the peer credentials on struct
> sock.  This gives enough information to convert the peer credential
> information to a value relative to whatever namespace the socket is in
> at the time.
>
> This removes nasty surprises when using SO_PEERCRED on socket
> connetions where the processes on either side are in different pid and
> user namespaces.
>
> Signed-off-by: Eric W. Biederman<ebiederm@xmission.com>
>    

Acked-by: Daniel Lezcano <daniel.lezcano@free.fr>

