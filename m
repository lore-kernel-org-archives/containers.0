From: Krzysztof Taraszka <krzysztof.taraszka-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org>
Subject: Re: [lxc-devel] Memory Resources
Date: Mon, 24 Aug 2009 02:58:23 +0200
Message-ID: <ac1c4bf20908231758i13fef75p6f8a0fd7a4a425ec@mail.gmail.com>
References: <ac1c4bf20908230513q383fb338ne02e8f19f6ef18a6@mail.gmail.com>
	<4A916BC9.8040905@free.fr>
	<ac1c4bf20908230959j4cda58cel3bcf4f3822d50bb1@mail.gmail.com>
	<4A9183B2.7090005@free.fr>
	<ac1c4bf20908231117sb180e78q3eed64db3573ec35@mail.gmail.com>
	<ac1c4bf20908231138j2ce7bb48v69a8ac8ede6bc314@mail.gmail.com>
	<ac1c4bf20908231222t182e6ca6u716b98e13d85cbad@mail.gmail.com>
	<4A91A103.6020207@free.fr>
	<ac1c4bf20908231318v1586c2ciffd3df5fe1b70c20@mail.gmail.com>
	<4A91ADE1.9090204@free.fr>
Reply-To: kt-S89nZTSLPHGGdvJs77BJ7Q@public.gmane.org
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
In-Reply-To: <4A91ADE1.9090204-GANU6spQydw@public.gmane.org>
List-Unsubscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linux-foundation.org/pipermail/containers>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linux-foundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>
Cc: Linux Containers <containers-qjLDD68F18O7TbgM5vRIOg@public.gmane.org>, lxc-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: containers.vger.kernel.org

2009/8/23 Daniel Lezcano <daniel.lezcano-GANU6spQydw@public.gmane.org>

(...)


> With the lxc tools I did:
>
>        lxc-execute -n foo /bin/bash
>        echo 268435456 > /cgroup/foo/memory.limit_in_bytes
>        mount --bind /cgroup/foo/memory.meminfo /proc/meminfo
>        for i in $(seq 1 100); do sleep 3600 & done


(...)


>
> :)
>
>
hmmm... I think that access to the cgroup inside container is very risk
because I am able to manage for example memory resources (what if I am not
the host owner and... I can give me via non-secure mounted /cgroup (inside
container) all available memory resources...).
I think that the /proc/meminfo should be pass to the container in the other
way, but this is the topic for the other thread.
