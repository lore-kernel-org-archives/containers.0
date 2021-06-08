Received: from mout.kundenserver.de (mout.kundenserver.de [212.227.17.13])
	(using TLSv1.2 with cipher ECDHE-RSA-AES256-GCM-SHA384 (256/256 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id B1ED32FAD
	for <containers@lists.linux.dev>; Tue,  8 Jun 2021 09:38:18 +0000 (UTC)
Received: from [192.168.1.155] ([77.7.0.189]) by mrelayeu.kundenserver.de
 (mreue109 [212.227.15.183]) with ESMTPSA (Nemesis) id
 1MjjGX-1l5cah3HQp-00lF5d; Tue, 08 Jun 2021 11:38:16 +0200
To: containers@lists.linux.dev,
 "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
From: "Enrico Weigelt, metux IT consult" <lkml@metux.net>
Subject: device namespaces
Message-ID: <ca7520c9-d260-6c87-43b9-f9be24ded50c@metux.net>
Date: Tue, 8 Jun 2021 11:38:16 +0200
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:78.0) Gecko/20100101
 Thunderbird/78.10.0
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: tl
Content-Transfer-Encoding: 8bit
X-Provags-ID: V03:K1:wxk78eUumZYNeOehK+YAmlLZTGCSWO3ghgFrKwZ1SPOQdNhz1ZM
 GdYoMpQoe+BAap7LC+pC5TIylANATBgsGirjYKOLa2T3RHdVDVaQo5MDPRa4bfw6TZBZoYY
 RaixW3pVbW/E7B8yip7Ewf+iU/8E/mUHbK15MJ0Gj2lVToUdRy05Gz6JYrNLH3omwp8Wcd4
 FkmHUPW3SVrZn5lVIPzBg==
X-Spam-Flag: NO
X-UI-Out-Filterresults: notjunk:1;V03:K0:Yp3wVbPV/tU=:pGuDUOoK8jP0HwtYX8i4be
 uUWOoaAGoKZ99Cv+ndQIbNm2sT7dXxR1/v3MqtYhONIki0ketzitptG77//X7N6vUI/bxiBEt
 lhiW59Y0By9FpnZCNgrQ3zDY5IB8z1RSFojKPUUAQ8KfsoKwwYcEgzvzBLex2vA1yAZBODBwl
 jJzJRhfAhAEs2TBs60PUC/Ivt/PDWIebjmAJQ2nIXzsHr0AXfg233ADLHnn3yc+/uqJUn+jWq
 acq8n+4V0OuQ8q4vtVQOqcXFyd2SnH9oKBTNFBoxLDZ9yUmcbVFYj3+C9dNGvTvJnXvgOIoJH
 jfX5zwD8vhHzt+NdtJKuCy2cWfrh041pAE3FNHVjIVpiZhx4iTvA9naR5D0jChfYyuNP79CxG
 QNIblvffwgNhKzlcOe84xR77hyzgkhwPWrjW2vJmYDULM8vV9UfenMzTClBvwsmrcKiMw5zua
 aCwS1QjC3J0q4HxqogmKE+zG59VjO8mQl12emcsWuNq0rPcsxx3vKenBnwLgL+9bsz3F/Xk5M
 Lza89StjjAenDPH11GF47I=

Hello folks,


I'm going to implement device namespaces, where containers can get an
entirely different view of the devices in the machine (usually just a
specific subset, but possibly additional virtual devices).

For start I'd like to add a simple mapping of dev maj/min (leaving aside
sysfs, udev, etc). An important requirement for me is that the parent ns
can choose to delegate devices from those it full access too (child
namespaces can do the same to their childs), and the assignment can
change (for simplicity ignoring the case of removing devices that are
already opened by some process - haven't decided yet whether they should
be forcefully closed or whether keeping them open is a valid use case).

The big question for me now is how exactly to do the table maintenance
from userland. We already have entries in /proc/<pid>/ns/*. I'm thinking
about using them as command channel, like this:

* new child namespaces are created with empty mapping
* mapping manipulation is done by just writing commands to the ns file
* access is only granted if the writing process itself is in the
  parent's device ns and has CAP_SYS_ADMIN (or maybe their could be some
  admin user for the ns ? or the 'root' of the corresponding user_ns ?)
* if the caller has some restrictions on some particular device, these
  are automatically added (eg. if you're restricted to readonly, you
  can't give rw to the child ns).

Is this a good way to go ? Or what would be a better one ?


--mtx

-- 
---
Hinweis: unverschlüsselte E-Mails können leicht abgehört und manipuliert
werden ! Für eine vertrauliche Kommunikation senden Sie bitte ihren
GPG/PGP-Schlüssel zu.
---
Enrico Weigelt, metux IT consult
Free software and Linux embedded engineering
info@metux.net -- +49-151-27565287
