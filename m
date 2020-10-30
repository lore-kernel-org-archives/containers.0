Return-Path: <SRS0=hUL4=EF=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.3 required=3.0 tests=BAYES_00,DKIM_ADSP_CUSTOM_MED,
	DKIM_INVALID,DKIM_SIGNED,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 255EEC4363A
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 12:19:14 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 4F81420724
	for <containers@archiver.kernel.org>; Fri, 30 Oct 2020 12:19:12 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=fail reason="signature verification failed" (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="o8Pn+YH4"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 4F81420724
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id 3489E2047B;
	Fri, 30 Oct 2020 12:19:12 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id xqZn6fM9FSxK; Fri, 30 Oct 2020 12:19:10 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 821982050D;
	Fri, 30 Oct 2020 12:19:10 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id 736B0C088B;
	Fri, 30 Oct 2020 12:19:10 +0000 (UTC)
Received: from fraxinus.osuosl.org (smtp4.osuosl.org [140.211.166.137])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 22024C0051
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 12:19:09 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by fraxinus.osuosl.org (Postfix) with ESMTP id 078E1865A5
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 12:19:09 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from fraxinus.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id NGgidIhODcnU
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 12:19:07 +0000 (UTC)
X-Greylist: domain auto-whitelisted by SQLgrey-1.7.6
Received: from mail-pf1-f195.google.com (mail-pf1-f195.google.com
 [209.85.210.195])
 by fraxinus.osuosl.org (Postfix) with ESMTPS id E952986591
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 12:19:07 +0000 (UTC)
Received: by mail-pf1-f195.google.com with SMTP id w65so5130446pfd.3
 for <containers@lists.linux-foundation.org>;
 Fri, 30 Oct 2020 05:19:07 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed; d=gmail.com; s=20161025;
 h=mime-version:references:in-reply-to:from:date:message-id:subject:to
 :cc; bh=z+1cvBFV+BbT045obJv5sfET1WD6zbSJq/rYiBWBg2Y=;
 b=o8Pn+YH4kcs5Ir63k+QjqV3fw1yk7AP9h/dm6/+wmJI12MR/faCDlGKXumHdYqlpoc
 Dii11zklXMChe1G6t/7sC2juQIOx4ADETdR4AK4omnqIBLrLOjmq6xzers02E18cyiEb
 gl4HgaZWY+npyq+92IagalGf1wbYrnRj6YPIdF7cHmdB6s/fBJo7i9036Srmc/K/uLva
 yyaofgMVlt1xY6CZGYzHQGZ68k5bwYeyqFfrsZcLUHqsC4LQHqdS2QyXOZ7fNyKNpYo4
 BKXPuI22ptBuocfbDtPvOcWQBHndd+4FKBG7ao1lTQKRpFDHoTwVE8FSc6eCCww62ueF
 EDoQ==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
 d=1e100.net; s=20161025;
 h=x-gm-message-state:mime-version:references:in-reply-to:from:date
 :message-id:subject:to:cc;
 bh=z+1cvBFV+BbT045obJv5sfET1WD6zbSJq/rYiBWBg2Y=;
 b=BEUUWwV2OEsmBM+RsTksFgGV48ZUHp/Kyjsg/ZFD++iaLE8K5i+y3PLsFQh3lf7axN
 e/81V7Q3h54EO9ZI7584219L4Ej/uBD0eEXt981NWIslcOscNZjQlGdUl28ujBAOQSr/
 QsVcbdeCsiNXeYN/dy00cCermin+KhvOHlVtGqMfcOZro0gVlVDzRz4bV3x/Z4Z3aplB
 Opl6+UFQqAIVpjlOScuNC2yR+fZE4YSYpLfpdG6tnsWeJpj9KkeTLNP8lajhEt8ANCQa
 ETSGS/HcCzq597BQSsVCM/ZU1fPEuY6AsD26mWIkYgkFPllhTkG4mLussK4mIpBs4Syy
 Lx+g==
X-Gm-Message-State: AOAM530SVoIuivh7X+0USfvU+3WF0aaOuStTyikf/jATA1ZBjhy9kt2J
 KSPtxdxNs61tKhT5ig2unytM1ldwLbeuyjZR9wE=
X-Google-Smtp-Source: ABdhPJw9NKS06kO8N0f04yMRWi7OK7/vjW6hOd0bft0wy3RnoaaAGQQu8G/jHZBZdmuRZ8LiJGfLPJXZdXFVTOIOQwE=
X-Received: by 2002:a17:90a:5797:: with SMTP id
 g23mr2603183pji.184.1604060347403; 
 Fri, 30 Oct 2020 05:19:07 -0700 (PDT)
MIME-Version: 1.0
References: <cover.1602263422.git.yifeifz2@illinois.edu>
 <c2077b8a86c6d82d611007d81ce81d32f718ec59.1602263422.git.yifeifz2@illinois.edu>
 <202010091613.B671C86@keescook>
 <CABqSeARZWBQrLkzd3ozF16ghkADQqcN4rUoJS2MKkd=73g4nVA@mail.gmail.com>
 <202010121556.1110776B83@keescook>
 <CABqSeAT2-vNVUrXSWiGp=cXCvz8LbOrTBo1GbSZP2Z+CKdegJA@mail.gmail.com>
 <CABqSeASc-3n_LXpYhb+PYkeAOsfSjih4qLMZ5t=q5yckv3w0nQ@mail.gmail.com>
 <202010221520.44C5A7833E@keescook>
 <CABqSeAT4L65_uS=45uxPZALKaDSDocMviMginLOV2N0h-e1AzA@mail.gmail.com>
 <202010231945.90FA4A4AA@keescook>
In-Reply-To: <202010231945.90FA4A4AA@keescook>
From: YiFei Zhu <zhuyifei1999@gmail.com>
Date: Fri, 30 Oct 2020 07:18:55 -0500
Message-ID: <CABqSeAQ4cCwiPuXEeaGdErMmLDCGxJ-RgweAbUqdrdm+XJXxeg@mail.gmail.com>
Subject: Re: [PATCH v4 seccomp 5/5] seccomp/cache: Report cache data through
 /proc/pid/seccomp_cache
To: Kees Cook <keescook@chromium.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>,
 Giuseppe Scrivano <gscrivan@redhat.com>,
 Valentin Rothberg <vrothber@redhat.com>, Jann Horn <jannh@google.com>,
 YiFei Zhu <yifeifz2@illinois.edu>,
 Linux Containers <containers@lists.linux-foundation.org>,
 Tobin Feldman-Fitzthum <tobin@ibm.com>,
 kernel list <linux-kernel@vger.kernel.org>,
 Andy Lutomirski <luto@amacapital.net>, Hubertus Franke <frankeh@us.ibm.com>,
 David Laight <David.Laight@aculab.com>, Jack Chen <jianyan2@illinois.edu>,
 Dimitrios Skarlatos <dskarlat@cs.cmu.edu>,
 Josep Torrellas <torrella@illinois.edu>, Will Drewry <wad@chromium.org>,
 bpf <bpf@vger.kernel.org>, Tianyin Xu <tyxu@illinois.edu>
X-BeenThere: containers@lists.linux-foundation.org
X-Mailman-Version: 2.1.15
Precedence: list
List-Id: Linux Containers <containers.lists.linuxfoundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers@lists.linux-foundation.org>
List-Help: <mailto:containers-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>, 
 <mailto:containers-request@lists.linux-foundation.org?subject=subscribe>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

On Fri, Oct 23, 2020 at 9:51 PM Kees Cook <keescook@chromium.org> wrote:
> Do you have a test environment where you can compare the before/after
> of repeated kernel build times (or some other sufficiently
> complex/interesting) workload under these conditions:
>
> bare metal
> docker w/ seccomp policy disabled
> docker w/ default seccomp policy
>
> This is what I've been trying to construct, but it's really noisy, so
> I've been trying to pin CPUs and NUMA memory nodes, but it's not really
> helping yet. :P

Hi, sorry for the delay. The benchmarks took a while to get.

I got a bare metal test machine with Intel(R) Xeon(R) CPU E5-2660 v3 @
2.60GHz, running Ubuntu 18.04. Test kernels are compiled at
57a339117e52 ("selftests/seccomp: Compare bitmap vs filter overhead")
and 3650b228f83a ("Linux 5.10-rc1"), built with Ubuntu's
5.3.0-64-generic's config, then `make olddefconfig`. "Mitigations off"
indicate the kernel was booted with "nospectre_v2 nospectre_v1
no_stf_barrier tsx=off tsx_async_abort=off".

The benchmark was single-job make on x86_64 defconfig of 5.9.1, with
CPU affinity to set only processor #0. Raw results are appended below.
Each boot is tested by running the build directly and inside docker,
with and without seccomp. The commands used are attached below. Each
test is 4 trials, with the middle two (non-minimum, non-maximum) wall
clock time averaged. Results summary:

                Mitigations On                  Mitigations Off
                With Cache      Without Cache   With Cache      Without Cache
Native          18:17.38        18:13.78        18:16.08        18:15.67
D. no seccomp   18:15.54        18:17.71        18:17.58        18:16.75
D. + seccomp    20:42.47        20:45.04        18:47.67        18:49.01

To be honest, I'm somewhat surprised that it didn't produce as much of
a dent in the seccomp overhead in this macro benchmark as I had
expected.

Below are commands used and outputs from time command.

Commands used to start the docker containers:
docker run -w /srv/yifeifz2/linux-buildtest \
  --tmpfs /srv/yifeifz2/linux-buildtest:exec --rm -it ubuntu:18.04

docker run -w /srv/yifeifz2/linux-buildtest \
  --tmpfs /srv/yifeifz2/linux-buildtest:exec --rm -it \
  --security-opt seccomp=unconfined ubuntu:18.04

Commands used to install the toolchain inside docker:
apt -y update
apt -y dist-upgrade
apt -y install build-essential wget flex bison time libssl-dev bc libelf-dev

Commands to benchmark on native:
for i in {1..4}; do
    mkdir -p /srv/yifeifz2/linux-buildtest
    mount -t tmpfs tmpfs /srv/yifeifz2/linux-buildtest
    pushd /srv/yifeifz2/linux-buildtest
    wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.9.1.tar.xz
    tar xf linux-5.9.1.tar.xz
    cd linux-5.9.1
    make mrproper
    make defconfig
    taskset 0x1 time make -j1 > /dev/null
    popd
    umount /srv/yifeifz2/linux-buildtest
done

Commands to benchmark inside docker:
for i in {1..4}; do
    wget https://cdn.kernel.org/pub/linux/kernel/v5.x/linux-5.9.1.tar.xz
    tar xf linux-5.9.1.tar.xz
    pushd linux-5.9.1
    make mrproper
    make defconfig
    taskset 0x1 time make -j1 > /dev/null
    popd
    rm -rf linux-5.9.1 linux-5.9.1.tar.xz
done

==== with cache, mitigations on ====

973.52user 113.98system 18:16.51elapsed 99%CPU (0avgtext+0avgdata
239784maxresident)k
0inputs+217152outputs (0major+51937662minor)pagefaults 0swaps

973.74user 115.35system 18:18.41elapsed 99%CPU (0avgtext+0avgdata
239640maxresident)k
0inputs+217152outputs (0major+51933865minor)pagefaults 0swaps

973.31user 114.41system 18:17.37elapsed 99%CPU (0avgtext+0avgdata
239660maxresident)k
72inputs+217152outputs (0major+51936343minor)pagefaults 0swaps

971.76user 116.04system 18:17.39elapsed 99%CPU (0avgtext+0avgdata
239588maxresident)k
0inputs+217152outputs (0major+51936222minor)pagefaults 0swaps


961.44user 121.30system 18:15.30elapsed 98%CPU (0avgtext+0avgdata
239580maxresident)k
0inputs+217152outputs (0major+51555371minor)pagefaults 0swaps

961.86user 119.48system 18:13.96elapsed 98%CPU (0avgtext+0avgdata
239480maxresident)k
0inputs+217152outputs (0major+51552153minor)pagefaults 0swaps

961.68user 121.75system 18:15.78elapsed 98%CPU (0avgtext+0avgdata
239504maxresident)k
0inputs+217152outputs (0major+51559201minor)pagefaults 0swaps

960.80user 122.04system 18:18.99elapsed 98%CPU (0avgtext+0avgdata
239644maxresident)k
0inputs+217152outputs (0major+51557386minor)pagefaults 0swaps


1104.08user 124.48system 20:42.13elapsed 98%CPU (0avgtext+0avgdata
239544maxresident)k
984inputs+217152outputs (21major+51552022minor)pagefaults 0swaps

1101.78user 125.66system 20:40.80elapsed 98%CPU (0avgtext+0avgdata
239692maxresident)k
0inputs+217152outputs (0major+51546446minor)pagefaults 0swaps

1102.98user 126.03system 20:43.09elapsed 98%CPU (0avgtext+0avgdata
239592maxresident)k
0inputs+217152outputs (0major+51551238minor)pagefaults 0swaps

1103.34user 125.32system 20:42.82elapsed 98%CPU (0avgtext+0avgdata
239620maxresident)k
0inputs+217152outputs (0major+51554493minor)pagefaults 0swaps


==== without cache, mitigations on ====

967.19user 115.77system 18:17.20elapsed 98%CPU (0avgtext+0avgdata
239536maxresident)k
25112inputs+217152outputs (166major+51935958minor)pagefaults 0swaps

969.05user 114.18system 18:12.92elapsed 99%CPU (0avgtext+0avgdata
239544maxresident)k
0inputs+217152outputs (0major+51938961minor)pagefaults 0swaps

968.51user 116.50system 18:14.64elapsed 99%CPU (0avgtext+0avgdata
239716maxresident)k
0inputs+217152outputs (0major+51937686minor)pagefaults 0swaps

968.53user 115.13system 18:10.33elapsed 99%CPU (0avgtext+0avgdata
239628maxresident)k
0inputs+217152outputs (0major+51938033minor)pagefaults 0swaps


962.85user 121.56system 18:17.73elapsed 98%CPU (0avgtext+0avgdata
239736maxresident)k
0inputs+217152outputs (0major+51549715minor)pagefaults 0swaps

962.51user 121.74system 18:17.42elapsed 98%CPU (0avgtext+0avgdata
239480maxresident)k
0inputs+217152outputs (0major+51558249minor)pagefaults 0swaps

963.37user 121.24system 18:18.59elapsed 98%CPU (0avgtext+0avgdata
239224maxresident)k
0inputs+217152outputs (0major+51551031minor)pagefaults 0swaps

963.71user 120.75system 18:17.70elapsed 98%CPU (0avgtext+0avgdata
239460maxresident)k
0inputs+217152outputs (0major+51555583minor)pagefaults 0swaps


1103.35user 126.49system 20:45.59elapsed 98%CPU (0avgtext+0avgdata
239600maxresident)k
984inputs+217152outputs (21major+51557916minor)pagefaults 0swaps

1103.01user 126.69system 20:45.36elapsed 98%CPU (0avgtext+0avgdata
239708maxresident)k
232inputs+217152outputs (0major+51560311minor)pagefaults 0swaps

1102.97user 127.13system 20:44.73elapsed 98%CPU (0avgtext+0avgdata
239440maxresident)k
0inputs+217152outputs (0major+51552998minor)pagefaults 0swaps

1103.09user 127.01system 20:44.48elapsed 98%CPU (0avgtext+0avgdata
239448maxresident)k
0inputs+217152outputs (0major+51559328minor)pagefaults 0swaps


==== with cache, mitigations off ====

971.35user 114.45system 18:16.36elapsed 99%CPU (0avgtext+0avgdata
239740maxresident)k
1584inputs+217152outputs (10major+51937572minor)pagefaults 0swaps

971.75user 115.18system 18:16.04elapsed 99%CPU (0avgtext+0avgdata
239648maxresident)k
0inputs+217152outputs (0major+51944016minor)pagefaults 0swaps

972.03user 114.47system 18:16.12elapsed 99%CPU (0avgtext+0avgdata
239368maxresident)k
744inputs+217152outputs (0major+51946745minor)pagefaults 0swaps

970.59user 115.13system 18:15.21elapsed 99%CPU (0avgtext+0avgdata
239736maxresident)k
0inputs+217152outputs (1major+51936971minor)pagefaults 0swaps


964.13user 121.15system 18:17.44elapsed 98%CPU (0avgtext+0avgdata
239496maxresident)k
0inputs+217152outputs (0major+51554855minor)pagefaults 0swaps

964.46user 120.73system 18:16.89elapsed 98%CPU (0avgtext+0avgdata
239492maxresident)k
0inputs+217152outputs (0major+51563668minor)pagefaults 0swaps

964.00user 121.71system 18:18.42elapsed 98%CPU (0avgtext+0avgdata
239504maxresident)k
0inputs+217152outputs (0major+51549101minor)pagefaults 0swaps

963.99user 121.46system 18:17.72elapsed 98%CPU (0avgtext+0avgdata
239644maxresident)k
0inputs+217152outputs (0major+51561705minor)pagefaults 0swaps


993.01user 123.83system 18:47.73elapsed 99%CPU (0avgtext+0avgdata
239648maxresident)k
984inputs+217152outputs (21major+51554203minor)pagefaults 0swaps

991.53user 125.49system 18:47.28elapsed 99%CPU (0avgtext+0avgdata
239380maxresident)k
0inputs+217152outputs (0major+51557014minor)pagefaults 0swaps

992.52user 124.53system 18:47.61elapsed 99%CPU (0avgtext+0avgdata
239344maxresident)k
0inputs+217152outputs (0major+51555681minor)pagefaults 0swaps

993.47user 125.01system 18:48.98elapsed 99%CPU (0avgtext+0avgdata
239448maxresident)k
0inputs+217152outputs (0major+51558830minor)pagefaults 0swaps


==== without cache, mitigations off ====

969.87user 118.18system 18:16.82elapsed 99%CPU (0avgtext+0avgdata
239640maxresident)k
0inputs+217152outputs (0major+51937042minor)pagefaults 0swaps

971.42user 114.62system 18:14.93elapsed 99%CPU (0avgtext+0avgdata
239840maxresident)k
0inputs+217152outputs (0major+51937617minor)pagefaults 0swaps

971.73user 114.40system 18:15.39elapsed 99%CPU (0avgtext+0avgdata
239724maxresident)k
0inputs+217152outputs (0major+51937768minor)pagefaults 0swaps

969.71user 117.13system 18:15.95elapsed 99%CPU (0avgtext+0avgdata
239680maxresident)k
0inputs+217152outputs (0major+51940505minor)pagefaults 0swaps


963.51user 121.32system 18:16.91elapsed 98%CPU (0avgtext+0avgdata
239516maxresident)k
0inputs+217152outputs (0major+51561337minor)pagefaults 0swaps

963.10user 120.75system 18:17.34elapsed 98%CPU (0avgtext+0avgdata
239464maxresident)k
0inputs+217152outputs (0major+51547338minor)pagefaults 0swaps

962.27user 122.48system 18:16.59elapsed 98%CPU (0avgtext+0avgdata
239544maxresident)k
0inputs+217152outputs (0major+51552060minor)pagefaults 0swaps

962.83user 120.21system 18:15.37elapsed 98%CPU (0avgtext+0avgdata
239496maxresident)k
0inputs+217152outputs (0major+51553345minor)pagefaults 0swaps


990.69user 125.78system 18:48.93elapsed 98%CPU (0avgtext+0avgdata
239440maxresident)k
984inputs+217152outputs (21major+51558142minor)pagefaults 0swaps

990.76user 126.01system 18:48.88elapsed 98%CPU (0avgtext+0avgdata
239800maxresident)k
0inputs+217152outputs (0major+51558483minor)pagefaults 0swaps

991.06user 125.99system 18:49.30elapsed 98%CPU (0avgtext+0avgdata
239412maxresident)k
0inputs+217152outputs (0major+51556462minor)pagefaults 0swaps

992.33user 124.77system 18:49.09elapsed 98%CPU (0avgtext+0avgdata
239684maxresident)k
0inputs+217152outputs (0major+51549745minor)pagefaults 0swaps

YiFei Zhu
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
