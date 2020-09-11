Return-Path: <SRS0=WNTF=CX=lists.linux-foundation.org=containers-bounces@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-3.7 required=3.0 tests=BAYES_00,
	HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_HELO_NONE,SPF_PASS,
	URIBL_BLOCKED autolearn=no autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 0D5C4C433E2
	for <containers@archiver.kernel.org>; Mon, 14 Sep 2020 00:57:39 +0000 (UTC)
Received: from silver.osuosl.org (smtp3.osuosl.org [140.211.166.136])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPS id 174DF208E4
	for <containers@archiver.kernel.org>; Mon, 14 Sep 2020 00:57:37 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 174DF208E4
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=sinokaiwei.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=containers-bounces@lists.linux-foundation.org
Received: from localhost (localhost [127.0.0.1])
	by silver.osuosl.org (Postfix) with ESMTP id B4AAC1FE32;
	Mon, 14 Sep 2020 00:57:37 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from silver.osuosl.org ([127.0.0.1])
	by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id NO6QlsbGMUyO; Mon, 14 Sep 2020 00:57:37 +0000 (UTC)
Received: from lists.linuxfoundation.org (lf-lists.osuosl.org [140.211.9.56])
	by silver.osuosl.org (Postfix) with ESMTP id 0EE1B1FD21;
	Mon, 14 Sep 2020 00:57:37 +0000 (UTC)
Received: from lf-lists.osuosl.org (localhost [127.0.0.1])
	by lists.linuxfoundation.org (Postfix) with ESMTP id E65ABC0864;
	Mon, 14 Sep 2020 00:57:36 +0000 (UTC)
Received: from whitealder.osuosl.org (smtp1.osuosl.org [140.211.166.138])
 by lists.linuxfoundation.org (Postfix) with ESMTP id 78562C0051
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 00:57:35 +0000 (UTC)
Received: from localhost (localhost [127.0.0.1])
 by whitealder.osuosl.org (Postfix) with ESMTP id 6080886759
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 00:57:35 +0000 (UTC)
X-Virus-Scanned: amavisd-new at osuosl.org
Received: from whitealder.osuosl.org ([127.0.0.1])
 by localhost (.osuosl.org [127.0.0.1]) (amavisd-new, port 10024)
 with ESMTP id kgxhZfv29X-k
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 00:57:34 +0000 (UTC)
X-Greylist: from auto-whitelisted by SQLgrey-1.7.6
Received: from mail.lvmail.top (unknown [188.127.251.204])
 by whitealder.osuosl.org (Postfix) with ESMTP id 57E2B86752
 for <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 00:57:34 +0000 (UTC)
Received: by mail.lvmail.top id hbr0041ef6cf for
 <containers@lists.linux-foundation.org>;
 Mon, 14 Sep 2020 03:57:37 +0300 (envelope-from
 <bounce-860-36866516-656-248@mail.lvmail.top>)
Date: Fri, 11 Sep 2020 12:39:44 +0300
To: "containers@lists.linux-foundation.org"
 <containers@lists.linux-foundation.org>
From: Tys <tys@sinokaiwei.com>
Subject: intel/AMD Mini PC iPC, 28 solution options
Message-ID: <a25602753a472050fd3b464f3ac16c4e@188.127.251.204>
X-Priority: 3
X-Mailer: Email Sending System
X-Complaints-To: mail@mail.lvmail.top
X-MessageID: NHx8fHwxODA3MTh8fHx8Y29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZ3x8fHwzfHx8fDF8fHx8MA%3D%3D
X-Report-Abuse: <http://www.lvmail.top/oem/report_abuse.php?mid=NHx8fHwxODA3MTh8fHx8Y29udGFpbmVyc0BsaXN0cy5saW51eC1mb3VuZGF0aW9uLm9yZ3x8fHwzfHx8fDF8fHx8MA%3D%3D>
MIME-Version: 1.0
X-Content-Filtered-By: Mailman/MimeDel 2.1.15
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
Reply-To: Tys <tys@sinokaiwei.com>
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Errors-To: containers-bounces@lists.linux-foundation.org
Sender: "Containers" <containers-bounces@lists.linux-foundation.org>

   [1]Mini PC


   Dear Purchasing Manager,



   Would you like to plan to buy Mini PC solutions of the same quality at
   a lower price?

   We are now looking for exclusive "VIP in-depth partners" and "VIP
   strategic partners" who are interested in our KaiMini and KaiWeiPC Mini
   PC brands products in more than 50 countries around the world.



   Special Mini PC Solutions:

   1, intel Mini PC, Class A, 9 option solutions.

   2, AMD Mini PC, Class A, 3 option solutions.

   3, Mini PC i3, Class A, 3 option solutions.

   4, Mini PC i5, Class A, 3 option solutions.

   5, Mini PC i7, Class A, 3 option solutions.

   6, Mini PC Board, Class A, 6 option solutions.

   7, Mini PC Stick, Class A, 2 option solutions.

   8, Fanless micro-sized Mini PC, Class A, 2 option solutions.



   We focus on reducing the procurement costs of our exclusive "VIP
   in-depth partners" and "VIP strategic partners". (7IOS)

    - "VIP in-depth Partners", 2.68% - 4.68% lower than market price.
   (0.6%)

    - "VIP strategic Partners", 5.88% - 8.88% lower than market price.
   (0.2%)

   I am very happy to tell you that our (ToC) first batch of products is
   expected to be officially launched in October. The details are as
   follows:

   1. intel J4105 8G+128G (4K 60Hz, 8GB LPDDR4/128GB SSD, Bluetooth5.0,
   windows 10 pro, Dual-Band Wifi)
   Amazon price per unit: 229 USD.
   Our wholesale price:
   Unit price of 1-50 units: 160 USD.
   Unit price of 50-100 units: 157 USD.
   Unit price of 100-200 units: 154 USD.
   Unit price of 200-500 units: 150 USD.

   2. intel J4115 8G+128G (4K 60Hz, 8GB LPDDR4/128GB SSD, Bluetooth5.0,
   windows 10 pro, Dual-Band Wifi)
   Amazon price per unit: 239 USD.
   Our wholesale price:
   Unit price of 1-50 units: 170 USD.
   Unit price of 50-100 units: 167 USD.
   Unit price of 100-200 units: 164 USD.
   Unit price of 200-500 units: 160 USD.

   Our US Amazon store is expected to start selling products in October.
   We also have many Mini PC products sold on the ToB market. The rising
   market for ToC omni-channel online sales will become more and more
   popular.
   In the next step, we will provide all customers with very beautiful
   promotional pictures and related copywriting of J4105/J4115 products .

   I am very happy to tell you that our (ToC) first batch of products is
   expected to be officially launched in October. The details are as
   follows:

   1. intel J4105 8G+128G (4K 60Hz, 8GB LPDDR4/128GB SSD, Bluetooth5.0,
   windows 10 pro, Dual-Band Wifi)
   Amazon price per unit: 229 USD.
   Our wholesale price:
   Unit price of 1-50 units: 160 USD.
   Unit price of 50-100 units: 157 USD.
   Unit price of 100-200 units: 154 USD.
   Unit price of 200-500 units: 150 USD.

   2. intel J4115 8G+128G (4K 60Hz, 8GB LPDDR4/128GB SSD, Bluetooth5.0,
   windows 10 pro, Dual-Band Wifi)
   Amazon price per unit: 239 USD.
   Our wholesale price:
   Unit price of 1-50 units: 170 USD.
   Unit price of 50-100 units: 167 USD.
   Unit price of 100-200 units: 164 USD.
   Unit price of 200-500 units: 160 USD.

   Our US Amazon store is expected to start selling products in October.
   We also have many Mini PC products sold on the ToB market. The rising
   market for ToC omni-channel online sales will become more and more
   popular.
   In the next step, we will provide all customers with very beautiful
   promotional pictures and related copywriting of J4105/J4115 products.
   NOW, We are developing more and more designs for the new year, we trust
   they will be very nice selling in your country, it is our plesure to
   show you first, we still have more.



   Thank you in advance.

   Yours sincerely,

   Tys


   .

References

   1. http://www.sinokaiwei.com/
_______________________________________________
Containers mailing list
Containers@lists.linux-foundation.org
https://lists.linuxfoundation.org/mailman/listinfo/containers
