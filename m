Received: from mail-oi1-f196.google.com (mail-oi1-f196.google.com [209.85.167.196])
	(using TLSv1.2 with cipher ECDHE-RSA-AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by smtp.subspace.kernel.org (Postfix) with ESMTPS id 4BF68184A
	for <containers@lists.linux.dev>; Tue, 14 Jun 2022 07:47:55 +0000 (UTC)
Received: by mail-oi1-f196.google.com with SMTP id l81so10644129oif.9
        for <containers@lists.linux.dev>; Tue, 14 Jun 2022 00:47:55 -0700 (PDT)
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20210112;
        h=mime-version:from:date:message-id:subject:to;
        bh=tfaG4F5JCykBzdjcFUsotTOazkiqxBkaKNk3DQnlq0g=;
        b=jna8qeUo4kfzIe3k2GI5UVEmwRs58/NI2ZF+JMiyPcohu2uJuRY8l1cCA3EoChTaCO
         Q1Ynj6map2GETIL25X2Gm1c7UFI+Mg9E2gxE1h9hGI3t3AOIBv2MsvuTT2Jj8fmNqeUt
         kx0y254qJrb0WSv5wV52W7TF/HJaEF2tLXePge77rL3WcD+tPtrXI68IadKXMJhyGLJA
         rKmgRAG5nVGK4nh2Vg4JcS7yrb6nrVQ9FYyZMu2Gj+c1hfBH4IZR7qKN1vaS5u5bmjNX
         yKrMm0QoXFrdHKQfWmZdP8rcM4gre8TcWBmuNAmklJLljcrKk7QEEFHLL+XJbEzo0Q8f
         3gDg==
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20210112;
        h=x-gm-message-state:mime-version:from:date:message-id:subject:to;
        bh=tfaG4F5JCykBzdjcFUsotTOazkiqxBkaKNk3DQnlq0g=;
        b=H/5+XxH+ovyRaZ4383udP0E1TbdUFx5ZLpekznGDwXKkWt9MZsQbaYCzTKCIEveJ8i
         ZV9Sb1h0CAAADZlbexMdjAFPPmoE43CPIgkQbwQbT/rB/ctkMma2BHmJJcb3yalQSfTm
         sP1GLQonxF+8ACLPQ6Ca7vZOitJekhTXvIdmYamJossl7t3jWrGU966Vy3VrZAZSIUF0
         3eWf640wyvVQfRBgrnUqHtJiJkJfS0KbK6sLKhDASH1D1G+P+tu85dDsPZc/6WeGjnvY
         SdDGrX3VY+QqbhSi+qobeikVXKuLdriKVa7ujSLkMGfUgZBacQhlGYesikqayMbHJQ+l
         si5A==
X-Gm-Message-State: AOAM532jEazmT125Oewcoh4FWZLw13u+1obriobgXpMZtmNMoWPAVzhn
	6NRZt2+fC76JmvZO/g3WYs91IDNbVB6l175aNk4/dAj5ozEO4dDxA+fYsA==
X-Google-Smtp-Source: ABdhPJy+EoVzQ3c/xETbHYCj8D6RhTN3zU9qlnaVo3jN3SqHSsgrBVPRI5PxFl1CdUL7ZzfZgCsfpp6lZScHjf01MAo=
X-Received: by 2002:a05:6808:178a:b0:32f:134f:9d2 with SMTP id
 bg10-20020a056808178a00b0032f134f09d2mr1434777oib.59.1655192874310; Tue, 14
 Jun 2022 00:47:54 -0700 (PDT)
Precedence: bulk
X-Mailing-List: containers@lists.linux.dev
List-Id: <containers.lists.linux.dev>
List-Subscribe: <mailto:containers+subscribe@lists.linux.dev>
List-Unsubscribe: <mailto:containers+unsubscribe@lists.linux.dev>
MIME-Version: 1.0
From: Qingwei Xu <xqw.kernel@gmail.com>
Date: Tue, 14 Jun 2022 15:47:41 +0800
Message-ID: <CAFRajNYQyzDv+xwEnW-xoWBVmcg6mBNnhFx4m0cLG2R4tK=LNw@mail.gmail.com>
Subject: 
To: containers@lists.linux.dev
Content-Type: text/plain; charset="UTF-8"

subscribe containers
