From: Mail Delivery Subsystem <mailer-daemon-gM/Ye1E23mwN+BqQ9rBEUg@public.gmane.org>
Subject: Delivery Status Notification (Failure)
Date: Fri, 19 Jun 2015 04:39:07 +0000
Message-ID: <089e013d1d9c2e417b0518d78113@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Return-path: <containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/containers/>
List-Post: <mailto:containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
List-Help: <mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/containers>,
	<mailto:containers-request-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org?subject=subscribe>
Sender: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Errors-To: containers-bounces-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
To: containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
List-Id: containers.vger.kernel.org

Delivery to the following recipient failed permanently:

     wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org

Technical details of permanent failure: 
Google tried to deliver your message, but it was rejected by the relay smtp.idm.fr by smtp.idm.fr. [62.160.32.11].

The error that the other server returned was:
554 5.4.0 Error: too many hops


----- Original message -----

X-Gm-Message-State: ALoCoQmb0McadphxzT1cRRJDTCrplpR3W/dG3ZtWW4PEZK7mTDrG/z0eLkE9q8o7W/RPVVOS29m+TJmC6YdJ7vDAQ2epBI3k0a3nA5OYgJ/Ze/Ivy+FYt8UPampzZZC+wtbHVacy6vYe
X-Received: by 10.194.177.230 with SMTP id ct6mr21185330wjc.31.1434688747650;
        Thu, 18 Jun 2015 21:39:07 -0700 (PDT)
X-Received: by 10.194.177.230 with SMTP id ct6mr21185316wjc.31.1434688747541;
        Thu, 18 Jun 2015 21:39:07 -0700 (PDT)
Return-Path: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id a3si14784040wjb.4.2015.06.18.21.39.07
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:39:07 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Authentication-Results: mx.google.com;
       spf=fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) smtp.mail=containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by idm.fr (Postfix) with ESMTP id 6B489181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:39:06 +0200 (CEST)
Received: by wibdq8 with SMTP id dq8so7176459wib.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:39:07 -0700 (PDT)
X-Received: by 10.194.157.168 with SMTP id wn8mr21450833wjb.79.1434688747008;
        Thu, 18 Jun 2015 21:39:07 -0700 (PDT)
X-Received: by 10.194.157.168 with SMTP id wn8mr21450818wjb.79.1434688746903;
        Thu, 18 Jun 2015 21:39:06 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id k8si2442805wia.75.2015.06.18.21.39.06
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:39:06 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by idm.fr (Postfix) with ESMTP id EAB90181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:39:05 +0200 (CEST)
Received: by wicnd19 with SMTP id nd19so7622347wic.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:39:06 -0700 (PDT)
X-Received: by 10.194.248.196 with SMTP id yo4mr12905680wjc.86.1434688746496;
        Thu, 18 Jun 2015 21:39:06 -0700 (PDT)
X-Received: by 10.194.248.196 with SMTP id yo4mr12905671wjc.86.1434688746384;
        Thu, 18 Jun 2015 21:39:06 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id g14si17673196wjz.39.2015.06.18.21.39.06
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:39:06 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by idm.fr (Postfix) with ESMTP id 98037181C7D
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:39:04 +0200 (CEST)
Received: by wgbhy7 with SMTP id hy7so79593515wgb.2
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:39:05 -0700 (PDT)
X-Received: by 10.180.96.196 with SMTP id du4mr2557957wib.77.1434688745203;
        Thu, 18 Jun 2015 21:39:05 -0700 (PDT)
X-Received: by 10.180.96.196 with SMTP id du4mr2557950wib.77.1434688745100;
        Thu, 18 Jun 2015 21:39:05 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id r7si2458188wix.23.2015.06.18.21.39.04
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:39:04 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by idm.fr (Postfix) with ESMTP id 3A045181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:39:03 +0200 (CEST)
Received: by wicnd19 with SMTP id nd19so7424781wic.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:39:02 -0700 (PDT)
X-Received: by 10.194.200.73 with SMTP id jq9mr21900528wjc.52.1434688742490;
        Thu, 18 Jun 2015 21:39:02 -0700 (PDT)
X-Received: by 10.194.200.73 with SMTP id jq9mr21900511wjc.52.1434688742372;
        Thu, 18 Jun 2015 21:39:02 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id t19si2472581wij.38.2015.06.18.21.39.01
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f175.google.com (mail-wi0-f175.google.com [209.85.212.175])
	by idm.fr (Postfix) with ESMTP id EE353181EB1
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:39:00 +0200 (CEST)
Received: by wibdq8 with SMTP id dq8so7175243wib.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
X-Received: by 10.180.105.129 with SMTP id gm1mr2515527wib.51.1434688741568;
        Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
X-Received: by 10.180.105.129 with SMTP id gm1mr2515516wib.51.1434688741479;
        Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id hl4si2429105wib.66.2015.06.18.21.39.01
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by idm.fr (Postfix) with ESMTP id 8858D181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:39:00 +0200 (CEST)
Received: by wiga1 with SMTP id a1so7467439wig.0
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
X-Received: by 10.180.19.100 with SMTP id d4mr2658853wie.29.1434688741127;
        Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
X-Received: by 10.180.19.100 with SMTP id d4mr2658840wie.29.1434688741027;
        Thu, 18 Jun 2015 21:39:01 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id i18si17610493wjs.183.2015.06.18.21.39.00
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:39:00 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wg0-f47.google.com (mail-wg0-f47.google.com [74.125.82.47])
	by idm.fr (Postfix) with ESMTP id E00E6181C7D
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:59 +0200 (CEST)
Received: by wgfq1 with SMTP id q1so32909237wgf.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:39:00 -0700 (PDT)
X-Received: by 10.194.120.230 with SMTP id lf6mr22327144wjb.41.1434688740038;
        Thu, 18 Jun 2015 21:39:00 -0700 (PDT)
X-Received: by 10.194.120.230 with SMTP id lf6mr22327137wjb.41.1434688739952;
        Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id cu9si2385387wib.124.2015.06.18.21.38.59
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by idm.fr (Postfix) with ESMTP id 02B8A181E04
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:58 +0200 (CEST)
Received: by wicnd19 with SMTP id nd19so7424115wic.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
X-Received: by 10.180.86.73 with SMTP id n9mr2596951wiz.78.1434688739534;
        Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
X-Received: by 10.180.86.73 with SMTP id n9mr2596947wiz.78.1434688739454;
        Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id el3si2456899wib.24.2015.06.18.21.38.59
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by idm.fr (Postfix) with ESMTP id 7E7E4181DDB
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:58 +0200 (CEST)
Received: by wicnd19 with SMTP id nd19so7620768wic.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
X-Received: by 10.194.120.198 with SMTP id le6mr22120590wjb.133.1434688739092;
        Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
X-Received: by 10.194.120.198 with SMTP id le6mr22120581wjb.133.1434688739001;
        Thu, 18 Jun 2015 21:38:59 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id g4si17650404wjs.106.2015.06.18.21.38.58
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:58 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by idm.fr (Postfix) with ESMTP id B881C181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:57 +0200 (CEST)
Received: by wicnd19 with SMTP id nd19so7423790wic.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:58 -0700 (PDT)
X-Received: by 10.180.9.111 with SMTP id y15mr2719692wia.18.1434688738245;
        Thu, 18 Jun 2015 21:38:58 -0700 (PDT)
X-Received: by 10.180.9.111 with SMTP id y15mr2719682wia.18.1434688738154;
        Thu, 18 Jun 2015 21:38:58 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id s1si2498232wiy.4.2015.06.18.21.38.57
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:57 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f180.google.com (mail-wi0-f180.google.com [209.85.212.180])
	by idm.fr (Postfix) with ESMTP id B8A44181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:56 +0200 (CEST)
Received: by wibdq8 with SMTP id dq8so7174215wib.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:57 -0700 (PDT)
X-Received: by 10.194.177.230 with SMTP id ct6mr21184295wjc.31.1434688737326;
        Thu, 18 Jun 2015 21:38:57 -0700 (PDT)
X-Received: by 10.194.177.230 with SMTP id ct6mr21184288wjc.31.1434688737242;
        Thu, 18 Jun 2015 21:38:57 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id dd10si2451160wib.30.2015.06.18.21.38.57
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:57 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by idm.fr (Postfix) with ESMTP id 374E9181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:56 +0200 (CEST)
Received: by wiga1 with SMTP id a1so7466412wig.0
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:56 -0700 (PDT)
X-Received: by 10.194.60.226 with SMTP id k2mr14768980wjr.10.1434688736757;
        Thu, 18 Jun 2015 21:38:56 -0700 (PDT)
X-Received: by 10.194.60.226 with SMTP id k2mr14768973wjr.10.1434688736648;
        Thu, 18 Jun 2015 21:38:56 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id fa9si2475881wid.33.2015.06.18.21.38.55
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:56 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wg0-f51.google.com (mail-wg0-f51.google.com [74.125.82.51])
	by idm.fr (Postfix) with ESMTP id 19884181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:55 +0200 (CEST)
Received: by wgbhy7 with SMTP id hy7so79591545wgb.2
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:55 -0700 (PDT)
X-Received: by 10.194.85.163 with SMTP id i3mr21410208wjz.141.1434688735696;
        Thu, 18 Jun 2015 21:38:55 -0700 (PDT)
X-Received: by 10.194.85.163 with SMTP id i3mr21410201wjz.141.1434688735606;
        Thu, 18 Jun 2015 21:38:55 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id fl20si17605456wjc.185.2015.06.18.21.38.55
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:55 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wi0-f174.google.com (mail-wi0-f174.google.com [209.85.212.174])
	by idm.fr (Postfix) with ESMTP id 30C6D181DDB
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:54 +0200 (CEST)
Received: by wiga1 with SMTP id a1so7466003wig.0
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:54 -0700 (PDT)
X-Received: by 10.194.5.135 with SMTP id s7mr22314608wjs.115.1434688734780;
        Thu, 18 Jun 2015 21:38:54 -0700 (PDT)
X-Received: by 10.194.5.135 with SMTP id s7mr22314593wjs.115.1434688734676;
        Thu, 18 Jun 2015 21:38:54 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id gf7si7709147wjd.98.2015.06.18.21.38.54
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:54 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by idm.fr (Postfix) with ESMTP id 50100181C5A
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:53 +0200 (CEST)
Received: by wgfq1 with SMTP id q1so32907992wgf.1
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:53 -0700 (PDT)
X-Received: by 10.180.206.33 with SMTP id ll1mr2529026wic.91.1434688733901;
        Thu, 18 Jun 2015 21:38:53 -0700 (PDT)
X-Received: by 10.180.206.33 with SMTP id ll1mr2529000wic.91.1434688733702;
        Thu, 18 Jun 2015 21:38:53 -0700 (PDT)
Received: from idm.fr ([62.160.32.11])
        by mx.google.com with ESMTP id el3si2456899wib.24.2015.06.18.21.38.53
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:53 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 62.160.32.11 as permitted sender) client-ip=62.160.32.11;
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by idm.fr (Postfix) with ESMTP id 38E7C181E04
	for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Fri, 19 Jun 2015 06:38:51 +0200 (CEST)
Received: by wgbhy7 with SMTP id hy7so79590871wgb.2
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>; Thu, 18 Jun 2015 21:38:52 -0700 (PDT)
X-Received: by 10.181.11.229 with SMTP id el5mr2745914wid.40.1434688732197;
        Thu, 18 Jun 2015 21:38:52 -0700 (PDT)
X-Received: by 10.181.11.229 with SMTP id el5mr2745904wid.40.1434688732111;
        Thu, 18 Jun 2015 21:38:52 -0700 (PDT)
Received: from localhost.localdomain ([81.19.151.153])
        by mx.google.com with ESMTP id en18si17658993wjd.70.2015.06.18.21.38.51
        for <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>;
        Thu, 18 Jun 2015 21:38:51 -0700 (PDT)
Received-SPF: fail (google.com: domain of containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org does not designate 81.19.151.153 as permitted sender) client-ip=81.19.151.153;
Received: from [81.19.151.153] by localhost.localdomain id 00qLgrcldNLu with SMTP; Fri, 19 Jun 2015 06:38:51 +0200
Date: Fri, 19 Jun 2015 06:38:51 +0200
From: <containers-cunTk1MwBs9QetFLy7KEm3xJsTq8ys+cHZ5vskTnxNA@public.gmane.org>
X-Mailer: The Bat! (v3.6.24.9) Educational
X-Priority: 3 (Normal)
Message-ID: <19978848.81011094780544-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
To: <wquest-5vFT0/cY5Q5QFI55V6+gNQ@public.gmane.org>
Subject: Re: Details facture 6009921.
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Bonjour, wquest

Desole pour le retard, voici une nouvelle liste de prix et de details
http://jackkunkels.nl/PosteIDFR984709264.zip?KY2Af

--
Cordialement
Il etait temps pour un peu de rien.
Tel.: 04-91-13-91-46
