From: "Paul Menage" <menage@google.com>
Subject: Re: [Devel] [PATCH 1/14][NETNS]: Introduce the net-subsys id generator.
Date: Thu, 10 Apr 2008 10:37:53 -0700
Message-ID: <6599ad830804101037m29d59f8dh85e27ceefc76f8f2@mail.gmail.com>
References: <47FE2AD4.9080609@openvz.org> <47FE2BB5.4070708@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
In-Reply-To: <47FE2BB5.4070708@openvz.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Cc: Linux Netdev List <netdev@vger.kernel.org>, Linux Containers <containers@lists.osdl.org>, Denis Lunev <den@openvz.org>, Benjamin Thery <benjamin.thery@bull.net>
List-Id: containers.vger.kernel.org

On Thu, Apr 10, 2008 at 8:01 AM, Pavel Emelyanov <xemul@openvz.org> wrote:
>  +int register_pernet_gen_device(int *id, struct pernet_operations *ops)
>  +{
>  +       int error;
>  +       mutex_lock(&net_mutex);
>  +again:
>  +       error = ida_get_new_above(&net_generic_ids, 1, id);
>  +       if (error) {
>  +               if (error == -EAGAIN) {
>  +                       ida_pre_get(&net_generic_ids, GFP_KERNEL);
>  +                       goto again;
>  +               }

Shouldn't you handle non-EAGAIN errors here?

Paul
